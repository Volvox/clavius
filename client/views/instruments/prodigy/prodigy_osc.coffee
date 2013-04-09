Template.prodigy_osc.rendered = ->
  canvas = @find 'canvas'
  canvas.height = $(canvas).parent().height()
  canvas.width = $(canvas).parent().width()
  dial = new OscillatorDial(canvas)

  $(canvas).mousedown (e) -> dial.mousedown e
  $(canvas).mouseup (e) -> dial.mouseup e
  $(canvas).mousemove (e) -> dial.mousemove e
