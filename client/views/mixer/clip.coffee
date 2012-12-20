Template.clip.rendered = ->
  preloadPreview(@data.data)
  getPreview(@data.data).render(@find('canvas'))
  $(@find('.clip')).draggable
    containment: $('#multitrack-container')
    snap: true
    cursor: "pointer"
    scroll: true
    containment: "#multitrack-container", scroll:false
    cursorAt: 0,0,0,0
    stack: '.clip'
    snapMode: "both", grid: [50,100]
    snapTolerance: 0
    #snap: '.track',

  $(@find('.clip')).draggable
    axis: 'x'
    scroll: true
    containment: 'parent'

  $ =>
    $clips = $('.clips')
    $clip = $(@find('.clip'))
    $clip.css 'top', "#{$clips.offset().top + (($clips.outerHeight() - $clips.height()) / 2)}px"
    $clip.css 'left', "#{$clips.offset().left + @data.start}px"

Template.clip.events
  'dblclick': (e, template) ->
    getPreview(template.data.data).play()