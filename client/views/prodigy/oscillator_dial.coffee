class @OscillatorDial
  constructor: (@canvas) ->
    @radius = Math.min(@canvas.height, @canvas.width) * 0.45
    @thickness = 1.5
    @dotSpacing = [1, 3.5]
    @colorA = 'rgb(1, 140, 142)'
    @colorB = 'rgb(254, 239, 138)'
    @clicked = false
    @cursor = [0, 0]
    @ctx = @canvas.getContext '2d'

    @carrier = null
    @modulator = null
    @waves = []
    scaleX = @canvas.width / 16
    scaleY = @canvas.height / 32
    centerX = @canvas.width / 2
    centerY = @canvas.height / 2
    for wave, i in ['SINE', 'SQUARE', 'SAW', 'TRIANGLE']
      theta = i * Math.PI / 2
      x = centerX + Math.cos(theta) * 2 * @radius / 3
      y = centerY + Math.sin(theta) * 2 * @radius / 3
      @waves.push new OscillatorDialWave @ctx, i, @colorA, @colorB, x, y, scaleX, scaleY

    @draw()

  checkWaves: ->
    if sequencer? and @carrier is null and @modulator is null
      for wave in @waves
        if sequencer.instrument.params.osc1Waveform is wave.wave
          @carrier = wave
        if sequencer.instrument.params.modWaveform is wave.wave
          @modulator = wave

  draw: =>
    requestAnimationFrame @draw
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @checkWaves()
    @drawOuterCircle()
    @drawWaves()
    if @clicked
      @drawCircle @cursor[0], @cursor[1]
    if @carrier
      @drawCarrier()
    if @modulator
      @drawModulator()

  drawOuterCircle: ->
    @ctx.setLineDash @dotSpacing
    @ctx.lineWidth = @thickness
    @ctx.strokeStyle = @colorA
    @ctx.beginPath()
    @ctx.arc @canvas.width / 2, @canvas.height / 2, @radius, 0, 2 * Math.PI, true
    @ctx.stroke()

  drawWaves: ->
    for wave in @waves
      wave.draw()

  drawCircle: (x, y) ->
    radius = @waves[0].radius
    @ctx.setLineDash []
    @ctx.strokeStyle = @colorB
    @ctx.beginPath()
    @ctx.arc x, y, radius, 0, 2 * Math.PI, true
    @ctx.stroke()

  drawCarrier: ->
    @drawCircle @carrier.originX, @carrier.originY

    x = @cursor[0]
    y = @cursor[1]
    if @modulator
      x = @modulator.originX
      y = @modulator.originY

    dx = x - @carrier.originX
    dy = y - @carrier.originY
    dist = Math.sqrt(dx * dx + dy * dy)
    dx /= dist
    dy /= dist
    dx *= @waves[0].radius
    dy *= @waves[0].radius

    @ctx.setLineDash [1, 4]
    @ctx.beginPath()
    @ctx.moveTo @carrier.originX + dx, @carrier.originY + dy
    @ctx.lineTo x - dx, y - dy
    @ctx.stroke()

  drawModulator: ->
    @drawCircle @modulator.originX, @modulator.originY

  updateInstrument: ->
    sequencer.instrument.params.modWaveform = @modulator.wave
    sequencer.instrument.params.osc1Waveform = @carrier.wave
    sequencer.instrument.params.osc2Waveform = @carrier.wave

  mousedown: (e) ->
    x = e.offsetX
    y = e.offsetY
    @clicked = true
    if @carrier and @modulator
      @carrier = @modulator = null
    unless @carrier
      for wave in @waves
        if wave.contains x, y
          @carrier = wave

  mouseup: (e) ->
    x = e.offsetX
    y = e.offsetY
    @clicked = false
    for wave in @waves
      if wave.contains x, y
        if @carrier is null
          @carrier = wave
        else
          @modulator = wave
          @updateInstrument()

  mousemove: (e) ->
    x = e.offsetX
    y = e.offsetY
    @cursor = [x, y]
    for wave in @waves
      if wave.contains x, y
        wave.hovering = true
        @cursor = [wave.originX, wave.originY]
      else
        wave.hovering = false

class OscillatorDialWave
  constructor: (@ctx, @wave, @colorA, @colorB, @originX, @originY, @scaleX, @scaleY) ->
    @hovering = false
    @selected = false
    @radius = 1.1 * Math.max(@scaleX, @scaleY)

    if @wave is 0
      @fn = Math.sin
    else if @wave is 1
      @fn = @square
    else if @wave is 2
      @fn = @saw
    else if @wave is 3
      @fn = @triangle

  draw: ->
    @drawWave()

  drawWave: ->
    @ctx.setLineDash []
    @ctx.lineCap = 'round'
    @ctx.lineWidth = 3
    @ctx.strokeStyle = @colorA
    @ctx.beginPath()
    if @hovering
      t = Date.now() * 0.005
    else
      t = 0
    steps = 30
    for i in [-steps..steps]
      x = i / steps
      y = @originY + @fn(x * Math.PI + t) * @scaleY
      @ctx.lineTo @originX + x * @scaleX, y
    @ctx.stroke()

  square: (x) ->
    number = Math.sin(x)
    number && number / Math.abs(number)

  saw: (x) ->
    2.5 * (x / (2 * Math.PI) - Math.floor(0.5 + x / (2 * Math.PI)))

  triangle: (x) =>
    -2 + 2.0 * Math.abs @saw(x)

  contains: (x, y) ->
    Math.sqrt(Math.pow((x - @originX), 2) + Math.pow((y - @originY), 2)) < @radius

