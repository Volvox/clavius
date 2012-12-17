Template.clip_preview.rendered = ->
  preloadPreview(@data)
  getPreview(@data).render(@find('canvas'))

Template.clip_preview.events
  'dblclick': (e, template) ->
    getPreview(template.data).play()

