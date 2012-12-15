class Sequencer

  constructor: (canvas) ->
    @current = 0
    @hold = false
    Session.set('bpm', 120)
    Session.set('note', 15)
    @initializeCanvas canvas
    @fetchSounds(17)


    #keyboard commands
    Mousetrap.bind "space", =>
      sequencer.toggle()
      false
    Mousetrap.bind "shift+right", =>
      if @hold is true
        @tick
        @current = @current+1
        @highlightColumn(@current)
      else
        @tick
        sequencer.toggle()
        @current = @current+1
        @highlightColumn(@current)

      false
    Mousetrap.bind "shift+a", =>
      col = @current
      row = 19
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+w", =>
      col = @current
      row = 18
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+s", =>
      col = @current
      row = 17
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+e", =>
      col = @current
      row = 16
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+d", =>
      col = @current
      row = 15
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+r", =>
      col = @current
      row = 14
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+f", =>
      col = @current
      row = 13
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+g", =>
      col = @current
      row = 12
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+y", =>
      col = @current
      row = 11
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+h", =>
      col = @current
      row = 10
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+u", =>
      col = @current
      row = 9
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+j", =>
      col = @current
      row = 8
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+k", =>
      col = @current
      row = 7
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+o", =>
      col = @current
      row = 6
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+l", =>
      col = @current
      row = 5
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+p", =>
      col = @current
      row = 4
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+;", =>
      col = @current
      row = 3
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind "shift+[", =>
      col = @current
      row = 2
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false
    Mousetrap.bind '"', =>
      col = @current
      row = 1
      @state[col][row] = not @state[col][row]
      @drawCell(row, col)
      false


  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.padding = 10
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
        @tick()

  resizeGrid: ->
    @current = 0
    @columns = Session.get('columns') or 32
    @tile_height = Math.floor(@canvas.height / @sounds.length)
    @tile_width = Math.floor(@canvas.width / @columns)
    @state = []
    for col in [0...@columns]
      @state[col] = []
      for row in [0...@sounds.length]
        @state[col][row] = false

  drawGrid: ->
    ctx = @canvas.getContext '2d'
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.4)'

    for row in [0...@sounds.length]
      offset =  row * @tile_height
      ctx.beginPath()
      ctx.moveTo 0, offset
      ctx.lineTo @canvas.width, offset
      ctx.stroke()


    for col in [0...@columns]
      offset =  col * @tile_width
      ctx.beginPath()
      ctx.moveTo offset, 0
      ctx.lineTo offset, @canvas.height
      ctx.lineWidth = if col % 4 is 0 then 5 else 1
      ctx.stroke()

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    for col of @state
      for row of @state[col]
        if @state[col][row]
          x = col * @tile_width
          y = row * @tile_height
          radius = 5
          ctx.beginPath()
          ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
          ctx.fill()


  drawCell: (row, col) ->
    ctx = @canvas.getContext '2d'
    if @state[col][row]
      ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'
    x = col * @tile_width
    y = row * @tile_height
    radius = 8
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
    ctx.fill()


  highlightColumn: (col) ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    x = col * @tile_width
    ctx.fillRect x, 0, 5, @canvas.height

  playColumn: (col) ->
    for active, row in @state[col]
      if active
        audio = new Audio(@sounds[row]['preview-hq-mp3'])
        audio.play()

  toggle: ->
    $(".hold").toggleClass("held")
    if @hold is false
      Meteor.clearTimeout @cursor
      @hold = true
    else
      @cursor = Meteor.setTimeout @tick, (1000 * (Session.get('note') / Session.get('bpm'))) # sixteenth note
      @hold = false


  tick: =>
    @clear()
    @drawGrid()
    @draw()
    @highlightColumn(@current)
    @playColumn(@current)
    @current = (@current + 1) % @columns
    @cursor = Meteor.setTimeout @tick, (1000 * (Session.get('note') / Session.get('bpm'))) # sixteenth note

  click: (e) ->
    coords = @getCoords e
    row = Math.round(coords.y / @tile_height)
    col = Math.round(coords.x / @tile_width)
    @state[col][row] = not @state[col][row]
    @drawCell(row, col)

  getCoords: (e) ->
    x: e.pageX - @canvas.offsetLeft
    y: e.pageY - @canvas.offsetTop


Template.stepsequencer.rendered = ->
  canvas = @find('canvas')
  window.sequencer = new Sequencer(canvas)


Template.stepsequencer.bpm = ->
  Session.get('bpm')

Template.stepsequencer.events
  'click': (e) ->
    sequencer.click e
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
  'click .hold': (e) ->
    sequencer.toggle()