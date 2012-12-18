class Sequencer
  constructor: (canvas) ->
    @current = 0
    @cursor = 0
    @hold = false
    @transpose_sequence = false
    @initializeCanvas canvas
    @fetchSounds(17)
    Session.set('bpm', 120)
    Session.set('note', 0.25)
    Session.set('columns', 32)
    @octave = 1
    @letters = "awsedrfgyhujkolp;['".split ''

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
    @columns = Session.get('columns')
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

  bindKeys: () ->
    Mousetrap.reset()
    Mousetrap.bind "space", =>
      @toggle()

    #move green cursor to insert notes
    Mousetrap.bind "right", =>
      @cursor += 1
      if @cursor == @columns
        @cursor = 0
      @redraw(null, "cursor")

    Mousetrap.bind "left", =>
      @cursor -= 1
      if @cursor == 0
        @cursor = @columns-1
      @redraw(null, "cursor")

    #shift octave up and down
    Mousetrap.bind "shift+up", =>
      Session.set "display-octave", @octave
      if @octave > -2
        @octave -= 1

    Mousetrap.bind "shift+down", =>
      Session.set "display-octave", @octave
      if @octave < 2
        @octave += 1

    #playback sequence at corresponding pitch, and loop it while the key is held down.
    if @transpose_sequence
      @stop()
      for letter, i in @letters
        do (letter, i) =>
          Mousetrap.bind letter, (=>
            # @play()

            val = (letters.length)/(@sounds.length - 1 - i)
            pitchRate = Math.pow(2.0, 2.0 * (val - (0.90476 * 1.6)))
            console.log(pitchRate)

            contextPlayTime = @noteTime + @startTime # convert note time to context time
            for active, row in @state[@current]
              if active
                playBuffer @soundbank[row], 0, null, null, pitchRate
            # synchronize drawing with sound
            if @noteTime isnt @lastDrawTime
              @lastDrawTime = @noteTime
              @redraw()
            @advanceNote()
            ), "keydown"

    else

      @play()
      for letter, i in @letters
        do (letter, i) =>
          row = @sounds.length - 1 - i

          #insert mode
          Mousetrap.bind "shift+#{letter}", =>
            @state[@cursor][row] = not @state[@cursor][row]
            @drawDot(row, @cursor)

          #live mode
          Mousetrap.bind letter, =>
            @playRow(row)

  redraw: (column, kind) ->
    @clear()
    @drawGrid(column, kind)
    @draw()
    @highlightColumn @cursor, 'rgba(55, 255, 172, 0.8)'
    @highlightColumn @current

  drawGrid: () ->
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
          @drawDot row, col

  drawDot: (row, col) ->
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

  highlightColumn: (col, color) ->
      ctx = @canvas.getContext '2d'
      ctx.fillStyle = color or 'rgba(0, 0, 255, 0.4)'
      x = col * @tile_width + @tile_width
      ctx.fillRect x, 0, 5, @canvas.height

  playColumn: (col) ->
    for active, row in @state[col]
      if active
        if @soundbank[row].readyState is 4
           @soundbank[row].currentTime = 0
           @soundbank[row].play()

  playRow: (row, @octave) ->
    playBuffer @soundbank[row], 0, null, null, @octave
    move = @tile_height * row
    $('.arrow').css("top", move)

  schedule: () =>
    currentTime = audioContext.currentTime
    currentTime -= @startTime # normalize to 0
    # console.log @current, currentTime

    while @noteTime < currentTime + 0.200
      contextPlayTime = @noteTime + @startTime # convert note time to context time
      for active, row in @state[@current]
        if active
          playBuffer @soundbank[row], contextPlayTime, null, null, @octave

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

    @noteTime += @tickLength()

  play: ->
    @noteTime = 0.0
    @startTime = audioContext.currentTime + 0.005
    @schedule()

  stop: ->
    Meteor.clearTimeout @ticker

  tickLength: ->
    Session.get('note') * (60.0 / Session.get('bpm'))

  toggle: ->
    $(".hold").toggleClass("held")
    @hold = not @hold
    @hold = if false then @stop() else @play()


  click: (e, force) ->
    coords = @getCoords e
    row = Math.round(coords.y / @tile_height) - 1
    col = Math.round(coords.x / @tile_width) - 1
    if row in [0...@sounds.length] and col in [0...@columns]
      if force?
        @state[col][row] = force
      else
        @state[col][row] = not @state[col][row]
      @drawDot row, col

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
            stop: col * @tickLength() + @soundbank[row].duration
    notes[notes.length - 1].stop = @columns * @tickLength()
    notes: notes
    sounds: @sounds
    title: title
    state: @state
    columns: Session.get('columns')
    bpm: Session.get('bpm')


  buildLib: (exportObject) ->
    Meteor.call("createClip", exportObject)

  reset: ->
    for col in [0...@columns]
      @state[col] = []
      for row in [0...@sounds.length]
        @state[col][row] = false

  seed: (clipObject) ->
    #need to convert audio time to canvas divide start time by the time of one colum u get the column
    bpm = clipObject.bpm
    notes = clipObject.notes
    columns = clipObject.columnsCount
    sounds = clipObject.sounds
    state = clipObject.state

    @reset()
    Session.set('bpm', bpm)
    Session.set('columns', columns)
    for col of state
      for active, row in state[col]
        if active
          @state[col][row] = true
          @drawDot row, col
        else
          @state[col][row] = false


Template.sequencer.bpm = ->
  Session.get('bpm')

Template.sequencer.hidden = ->
  Session.get('hidden')

Template.sequencer.octave = ->
  Session.get('display-octave')

Template.sequencer.events
  'change .bpm': (e) ->
    val =  Number($(e.srcElement).val())
    if val > 0
      Session.set 'bpm', val
  'change .note': (e) ->
    val =  Number($(e.srcElement).val())
    Session.set 'note', val
  'change .bars': (e) ->
    val =  Number($(e.srcElement).val())
    Session.set 'columns', val
    sequencer.resizeGrid()
  'change .packId': (e) ->
    val = Number($(e.srcElement).val())
    sequencer.fetchSounds(val)
    e.srcElement.blur()
  'click .hold': (e) ->
    sequencer.toggle()
  'click a.btn': (e) ->
    e.preventDefault()
    title = $("#name-submit").val()
    sequencer.buildLib(sequencer.export(title))
  'click #save': (e) ->
    e.preventDefault()
    Session.set 'hidden', true
  'click #clear': (e) ->
    sequencer.reset()
  'click #toggle-trans': (e) ->
    e.preventDefault()
    text = $("#toggle-trans").text()
    $("#toggle-trans").toggleClass("btn btn-small btn-primary").text(if text is "OFF" then "ON" else "OFF")
    sequencer.transpose_sequence = not sequencer.transpose_sequence
    sequencer.bindKeys()