Template.pattern_preview.rendered = ->
  preloadPreview(@data)
  getPreview(@data).render(@find('canvas'), "dots")

Template.clip_list.selected = ->
  (if Session.equals("selected-pattern", @_id) then "selected" else "")

Template.pattern_preview.events
  'dblclick': (e, template) ->
    getPreview(template.data).play()

  'click': (e) ->
    # get object from collection with the corresponding _id
    clipObject = Clips.findOne( _id: $(e.srcElement).data('id') )
    clipPreview = new ClipPreview(clipObject)
    # Session.set "selected-pattern", @_id
    console.log clipObject
    sequencer.import(clipObject)