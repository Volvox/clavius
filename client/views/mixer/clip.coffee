Template.clip.rendered = ->
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

Template.clip.width = ->
  @stop - @start

Template.clip.left = ->
  @start

Template.clip.events
  'dblclick': (e, template) ->
    getPreview(template.data.data).play()