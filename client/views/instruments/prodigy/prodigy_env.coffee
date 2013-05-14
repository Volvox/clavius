Template.prodigy_env.rendered = ->
  canvas = @find 'canvas'
  canvas.height = $(canvas).parent().height()
  canvas.width = $(canvas).parent().width()
  envelope = new OscillatorEnvelope(canvas)

  $(canvas).mousedown (e) -> envelope.mousedown e
  $(canvas).mouseup (e) -> envelope.mouseup e
  $(canvas).mousemove (e) -> envelope.mousemove e
