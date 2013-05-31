class OscillatorButton
  constructor: (@canvas, @wave, @color) ->
    @ctx = @canvas.getContext '2d'
    @ctx.lineCap = 'round'
    @ctx.lineWidth = 2
    @ctx.strokeStyle = @color

    @width = $(@canvas).width()
    @height = $(@canvas).height()

    @hovering = false
    @selected = false

    @draw()

  draw: =>
    @ctx.clearRect 0, 0, @width, @height

    if @wave is 0
      @fn = Math.sin
    else if @wave is 1
      @fn = @square
    else if @wave is 2
      @fn = @saw
    else if @wave is 3
      @fn = @triangle

    @drawWave()

  drawWave: ->
    @ctx.beginPath()
    if @hovering
      t = Date.now() * 0.005
    else
      t = 0
    steps = 80
    for i in [-steps..steps]
      x = i / steps
      y = (@height / 2) + @fn(3 * Math.PI / 2 + x * Math.PI + t) * (@height / 6)
      @ctx.lineTo (@width / 2) + x * (@width / 3), y
    @ctx.stroke()

  square: (x) ->
    number = Math.sin(x)
    number && number / Math.abs(number)

  saw: (x) ->
    x += 3 * Math.PI / 2
    2.0 * (x / (2 * Math.PI) - Math.floor(0.5 + x / (2 * Math.PI)))

  triangle: (x) =>
    x += Math.PI
    -1 + 2.0 * Math.abs @saw(x)
