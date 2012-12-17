class Sequencer
  constructor: (canvas) ->
    @current = 0
    @hold = false
    @initializeCanvas canvas
    @fetchSounds(17)
    Session.set('bpm', 120)
    Session.set('note', 0.25)

  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $(canvas).parent().height()
    @canvas.width = $(canvas).parent().width()

  fetchSounds: (packId) ->
    $.ajax
      url: "http://www.freesound.org/api/packs/#{packId}/sounds?api_key=ec0c281cc7404d14b6f5216f96b8cd7c"
      dataType: "jsonp"
      error: (e) ->
        console.log(e)
      success: (data) =>
        @sounds = data.sounds
        @resizeGrid()
        @preloadSounds()
        @bindKeys()

  resizeGrid: ->
    @current = 0
    @columns = Session.get('columns') or 32
    @tile_height = Math.floor(@canvas.height / (@sounds.length + 1))
    @tile_width = Math.floor(@canvas.width / (@columns + 1))
    @state = []
    for col in [0...@columns]
      @state[col] = []
      for row in [0...@sounds.length]
        @state[col][row] = false

  preloadSounds: ->
    loader = new BufferLoader audioContext, (sound['preview-hq-ogg'] for sound in @sounds), (bufferList) =>
      @soundbank = bufferList
      @play()
    loader.load()

  bindKeys: ->
    Mousetrap.reset()

    Mousetrap.bind "space", =>
      @toggle()

    Mousetrap.bind "right", =>
      if @hold
        @current += 1
        if @current == @columns
          @current = 0
        @redraw()

    letters = "awsedrfgyhujkolp;['".split ''
    for letter, i in letters
      Mousetrap.bind "shift+#{letter}", ((row) =>
        =>
          @state[@current][row] = not @state[@current][row]
          @drawCell(row, @current)
      )(@sounds.length - 1 - i)

    for letter, i in letters
      Mousetrap.bind letter, ((row) =>
        =>
          @playRow(row)
      )(@sounds.length - 1 - i)

  redraw: (column) ->
    @clear()
    @drawGrid()
    @draw()
    if column?
      @highlightColumn column
    else
      @highlightColumn @current

  transposeKeys: ->
    text = $("#toggle-trans").text()
    $("#toggle-trans").toggleClass("btn btn-small btn-primary").text(if text is "OFF" then "ON" else "OFF")
    Mousetrap.reset()
    letters = "awsedrfgyhujkolp;['".split ''
    for letter, i in letters
      Mousetrap.bind letter, ((row) =>
        =>
          @playSequence(row)
      )(@sounds.length - 1 - i)

  playSequence: (row) ->
    pitch = row
    #playback sequence at this pitch

  drawGrid: ->
    ctx = @canvas.getContext '2d'
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.4)'

    for row in [0...@sounds.length]
      offset =  (1 + row) * @tile_height
      ctx.beginPath()
      ctx.moveTo 0, offset
      ctx.lineTo @canvas.width, offset
      ctx.stroke()

    for col in [0...@columns]
      offset =  (1 + col) * @tile_width
      ctx.beginPath()
      ctx.moveTo offset, 0
      ctx.lineTo offset, @canvas.height
      ctx.lineWidth = if col % 4 is 0 then 5 else 1
      ctx.stroke()

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: ->
    for col of @state
      for row of @state[col]
        if @state[col][row]
          @drawCell row, col

  drawCell: (row, col) ->
    ctx = @canvas.getContext '2d'
    if @state[col][row]
      ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'
    x = col * @tile_width + @tile_width
    y = row * @tile_height + @tile_height
    radius = 8
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
    ctx.fill()

  highlightColumn: (col) ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    x = col * @tile_width + @tile_width
    ctx.fillRect x, 0, 5, @canvas.height

  playBuffer: (buffer, time) ->
    source = audioContext.createBufferSource()
    source.buffer = buffer
    source.connect masterGainNode
    source.start time

  playColumn: (col) ->
    for active, row in @state[col]
      if active
        if @soundbank[row].readyState is 4
           @soundbank[row].currentTime = 0
           @soundbank[row].play()

  playRow: (row) ->
    @playBuffer @soundbank[row], 0
    move = @tile_height * row
    $('.arrow').css("top", move)

  schedule: =>
    currentTime = audioContext.currentTime
    currentTime -= @startTime # normalize to 0
    console.log @current, currentTime

    while @noteTime < currentTime + 0.200
      contextPlayTime = @noteTime + @startTime # convert note time to context time
      for active, row in @state[@current]
        if active
          @playBuffer @soundbank[row], contextPlayTime

      # synchronize drawing with sound
      if @noteTime isnt @lastDrawTime
        @lastDrawTime = @noteTime
        @redraw()

      @advanceNote()

    @ticker = Meteor.setTimeout @schedule, 0

  advanceNote: ->
    @current += 1
    if @current == @columns
      @current = 0

    secondsPerBeat = 60.0 / Session.get('bpm')
    @noteTime += Session.get('note') * secondsPerBeat

  play: ->
    @noteTime = 0.0
    @startTime = audioContext.currentTime + 0.005
    @schedule()

  stop: ->
    Meteor.clearTimeout @ticker

  tickLength: ->
    1000 * (Session.get('note') / Session.get('bpm'))

  toggle: ->
    $(".hold").toggleClass("held")
    if @hold is false
      @stop()
      @hold = true
    else
      @play()
      @hold = false

  click: (e, force) ->
    coords = @getCoords e
    row = Math.round(coords.y / @tile_height) - 1
    col = Math.round(coords.x / @tile_width) - 1
    if row in [0...@sounds.length] and col in [0...@columns]
      if force?
        @state[col][row] = force
      else
        @state[col][row] = not @state[col][row]
      @drawCell row, col

  getCoords: (e) ->
    x: e.pageX - @canvas.offsetLeft
    y: e.pageY - @canvas.offsetTop

  export: (title) ->
    notes = []
    for col of @state
      for active, row in @state[col]
        if active
          notes.push
            sound: row
            start: col * @tickLength()
            stop: col * @tickLength() + @tickLength()
    notes: notes
    sounds: @sounds
    title: title

  buildLib: (exportObject) ->
    Meteor.call("createClip", exportObject)

  reset: ->
    for col in [0...@columns]
      @state[col] = []
      for row in [0...@sounds.length]
        @state[col][row] = false
