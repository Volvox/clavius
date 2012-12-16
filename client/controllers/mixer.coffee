window.previewers = {}

Template.clip.rendered = ->
  unless previewers[@data.data._id]?
    previewers[@data.data._id] = new ClipPreview(@data.data)

  previewers[@data.data._id].render(@find('canvas'))

  $(@find('.clip')).draggable
    axis: 'x'

Template.mixer.song = ->
  Songs.findOne()

Template.clip.width = ->
  @stop - @start

Template.clip.left = ->
  @start

Template.clip.events
  'dblclick': (e, template) ->
    previewers[template.data.data._id].play()
