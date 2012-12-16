class Sequencer
  constructor: (canvas) ->
    @current = 0
    @hold = false
    Session.set('bpm', 120)
    Session.set('note', 15)
    @initializeCanvas canvas
    @fetchSounds(17)

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
        if @ticker?
          Meteor.clearTimeout @ticker
          @ticker = null
        @tick()

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
    @soundbank = []
    for sound in @sounds
      @soundbank.push new Audio(sound['preview-hq-ogg'])

  bindKeys: ->
    Mousetrap.bind "space", =>
      @toggle()

    Mousetrap.bind "right", =>
      if @hold
        @clear()
        @current += 1
        @highlightColumn(@current)
      else
        @tick
        @clear()
        @toggle()
        @current += 1
        @highlightColumn(@current)

    letters = "awsedrfgyhujkolp;['".split ''
    for letter, i in letters
      Mousetrap.bind "shift+#{letter}", ((row) =>
        =>
          @state[@current][row] = not @state[@current][row]
          @drawCell(row, @current)
      )(@sounds.length - 1 - i)

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

  playColumn: (col) ->
    for active, row in @state[col]
      if active
        @soundbank[row].currentTime = 0
        @soundbank[row].play()

  tickLength: ->
    1000 * (Session.get('note') / Session.get('bpm'))

  toggle: ->
    $(".hold").toggleClass("held")
    if @hold is false
      Meteor.clearTimeout @ticker
      @hold = true
    else
      @ticker = Meteor.setTimeout @tick, (1000 * (Session.get('note') / Session.get('bpm'))) # sixteenth note
      @hold = false

  tick: =>
    @clear()
    @drawGrid()
    @draw()
    @highlightColumn(@current)
    @playColumn(@current)
    @current = (@current + 1) % @columns
    @ticker = Meteor.setTimeout @tick, @tickLength()

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

  export: ->
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

