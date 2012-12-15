class Sequencer
  @canvas = null
  @sounds = null
  @state = null
  @tile_width = null
  @tile_height = null
  @columns = null
  @current = null
  @bpm = 120

  constructor: (canvas) ->
    @current = 0
    @initializeCanvas canvas
    @fetchSounds()

  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $('body').height()
    @canvas.width = $('body').width()

  fetchSounds: ->
    freesound.apiKey = "ec0c281cc7404d14b6f5216f96b8cd7c"
    freesound.get_pack 17, (pack) =>
      pack.get_sounds (data) =>
        @sounds = data.sounds
        @resizeGrid()
        @tick()

  resizeGrid: ->
    @columns = 16 * 4
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
          ctx.fillRect x, y, @tile_width, @tile_height

  drawCell: (row, col) ->
    ctx = @canvas.getContext '2d'
    if @state[col][row]
      ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'
    x = col * @tile_width
    y = row * @tile_height
    ctx.fillRect x, y, @tile_width, @tile_height
  
  highlightColumn: (col) ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    x = col * @tile_width
    ctx.fillRect x, 0, @tile_width, @canvas.height

  playColumn: (col) ->
    for active, row in @state[col]
      if active
        new Audio(@sounds[row]['preview-hq-mp3'])

  tick: =>
    @clear()
    @drawGrid()
    @draw()
    @highlightColumn(@current)
    @playColumn(@current)
    @current = (@current + 1) % @columns
    setTimeout @tick, (1000 * (15 / @bpm)) # sixteenth note

  click: (e) ->
    row = Math.floor(e.pageY / @tile_height)
    col = Math.floor(e.pageX / @tile_width)
    @state[col][row] = not @state[col][row]
    @drawCell(row, col)

Template.stepsequencer.rendered = ->
  canvas = @find('canvas')
  window.sequencer = new Sequencer(canvas)

Template.stepsequencer.events
  'click': (e) ->
    sequencer.click e

