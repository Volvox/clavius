Template.clip_preview.rendered = ->
  preloadPreview(@data)
  getPreview(@data).render(@find('canvas'))

  $(@find('.clip-preview')).draggable
    helper: 'clone'
    opacity: 0.5

Template.clip_preview.events
  'dblclick': (e, template) ->
    getPreview(template.data).play()

