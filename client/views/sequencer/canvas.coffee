Template.sequencer_canvas.rendered = ->
  unless App.sequencer?
    canvas = @find('canvas')
    App.sequencer = new PatternSequencer(canvas)

Template.sequencer_canvas.events
  'mousedown': (e) ->
    Session.set('mousedown', true)
    App.sequencer.click e
  'mouseup': (e) ->
    Session.set('mousedown', false)
  'mousemove': (e) ->
    if Session.get('mousedown')
      App.sequencer.click e, true
