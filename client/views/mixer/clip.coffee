Template.clip.rendered = ->
  preloadPreview(@data.data)
  getPreview(@data.data).render(@find('canvas'))

  $(@find('.clip')).draggable
    axis: 'x'
    grid: [40, 40]
    containment: 'parent'

  $ =>
    $clips = $('.clips')
    $clip = $(@find('.clip'))
    $clip.css 'top', "#{$clips.offset().top + (($clips.outerHeight() - $clips.height()) / 2)}px"
    $clip.css 'left', "#{$clips.offset().left + @data.start}px"

Template.clip.events
  'dblclick': (e, template) ->
    getPreview(template.data.data).play()

