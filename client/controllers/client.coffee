Meteor.subscribe 'clips'

Template.page_controller.page = (type) ->
  Session.get("current_page") == type

Template.stepsequencer.rendered = ->
  canvas = @find('canvas')
  window.sequencer = new Sequencer(canvas)

Template.stepsequencer.bpm = ->
  Session.get('bpm')

Template.stepsequencer.events
  'mousedown': (e) ->
    Session.set('mousedown', true)
    sequencer.click e
  'mouseup': (e) ->
    Session.set('mousedown', false)
  'mousemove': (e) ->
    if Session.get('mousedown')
      sequencer.click e, true
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
    e.srcElement.blur()
  'click .hold': (e) ->
    sequencer.toggle()
