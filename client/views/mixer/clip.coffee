Template.clip.rendered = ->
  preloadPreview(@data.data)
  getPreview(@data.data).render(@find('canvas'))

  $(@find('.clip')).draggable
    axis: 'x'

Template.clip.width = ->
  @stop - @start

Template.clip.left = ->
  @start

Template.clip.events
  'dblclick': (e, template) ->
    getPreview(template.data.data).play()

