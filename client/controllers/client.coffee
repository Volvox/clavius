Meteor.subscribe 'clips'
Meteor.subscribe 'songs'

Template.canvas.rendered = ->
  unless window.sequencer?
    canvas = @find('canvas')
    window.sequencer = new Sequencer(canvas)

Template.stepsequencer.bpm = ->
  Session.get('bpm')

Template.clip_list.clips = ->
  Clips.find()

Template.stepsequencer.hidden = ->
  Session.get('hidden')

Template.stepsequencer.events
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
  'click a.btn': (e) ->
    e.preventDefault()
    title = $("#nameSubmit").val()
    console.log(title)
    sequencer.buildLib(sequencer.export(title))
  'click #save': (e) ->
    e.preventDefault()
    Session.set 'hidden', true

Template.canvas.events
  'mousedown': (e) ->
    Session.set('mousedown', true)
    sequencer.click e
  'mouseup': (e) ->
    Session.set('mousedown', false)
  'mousemove': (e) ->
    if Session.get('mousedown')
      sequencer.click e, true
