Template.clip.rendered = ->
<<<<<<< HEAD
    preloadPreview(@data.data)
    getPreview(@data.data).render(@find('canvas'))
    bottom = $("div.draggable:first").scrollTop()
    right  = $("div.draggable:last").scrollTop()
    $(@find('.clip')).draggable
        # containment: $('#multitrack-container')
        #grid: [ 50, 100 ] #snaps from where you start dragging so not a good solution
        snap: true
        cursor: "pointer"
        containment: "#multitrack-container", scroll:false
        cursorAt: 0,0,0,0
        stack: '.clip'
        snapMode: "both", grid: [50,100]
        snapTolerance: 0
        #snap: '.track',
=======
  preloadPreview(@data.data)
  getPreview(@data.data).render(@find('canvas'))

  $(@find('.clip')).draggable
    axis: 'x'
    grid: [40, 40]
    containment: 'parent'
>>>>>>> c1a57ec9c21289f9a726e35911403f71e649c18f

  $ =>
    $clips = $('.clips')
    $clip = $(@find('.clip'))
    $clip.css 'top', "#{$clips.offset().top + (($clips.outerHeight() - $clips.height()) / 2)}px"
    $clip.css 'left', "#{$clips.offset().left + @data.start}px"

Template.clip.events
  'dblclick': (e, template) ->
    getPreview(template.data.data).play()
