Template.sequencer_canvas.rendered = ->
  unless window.sequencer?
    canvas = @find('canvas')
    window.sequencer = new Sequencer(canvas)
    sequencer.setInstrument(new SubtractiveSynthesizer)

Template.sequencer_canvas.events
  'mousedown': (e) ->
    Session.set('mousedown', true)
    sequencer.click e
  'mouseup': (e) ->
    Session.set('mousedown', false)
  'mousemove': (e) ->
    if Session.get('mousedown')
      sequencer.click e, true
