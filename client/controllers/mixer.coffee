window.previewers = {}

preloadPreview = (clip) ->
  unless previewers[clip._id]?
    previewers[clip._id] = new ClipPreview(clip)

getPreview = (clip) ->
  previewers[clip._id]

Template.clip.rendered = ->
  preloadPreview(@data.data)
  getPreview(@data.data).render(@find('canvas'))

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
    getPreview(template.data.data).play()

Template.clip_library.clips = ->
  Clips.find()

Template.clip_preview.rendered = ->
  preloadPreview(@data)
  getPreview(@data).render(@find('canvas'))

Template.clip_preview.events
  'dblclick': (e, template) ->
    getPreview(template.data).play()

