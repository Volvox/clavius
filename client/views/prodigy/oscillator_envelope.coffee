class OscillatorEnvelope
  constructor: (@canvas) ->
    @ctx = @canvas.getContext '2d'
    @colorA = 'rgb(1, 140, 142)'
    @colorB = 'rgb(254, 239, 138)'
    @attack = 2
    @attackMax = 50
    @decay = 15
    @decayMax = 50
    @sustain = 68
    @sustainMax = 100
    @release = 5
    @releaseMax = 200

    @draw()

  draw: =>
    requestAnimationFrame @draw
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.strokeStyle = @colorA
    @ctx.beginPath()
    @ctx.moveTo 0, @canvas.height
    @ctx.stroke()

  mousedown: (e) ->
    console.log e
    
  mouseup: (e) ->
    console.log e

  mousemove: (e) ->
    console.log e

