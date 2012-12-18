Template.clip_list.clips = ->
  Clips.find()

Template.clip_list.selected = ->
    (if Session.equals("selected-pattern", @_id) then "selected" else "")


Template.clip_list.events
  'click': (e) ->
    # get object from collection with the corresponding _id
    clipObject = Clips.findOne( _id: $(e.srcElement).data('id') )
    clipPreview = new ClipPreview(clipObject)
    Session.set "selected-pattern", @_id
    #Todo: add &#9998 symbol next to pattern title
    sequencer.seed(clipObject)

    # 'click #update': (e) ->
    #     db.collection.update( <query>, <update>, <options> )
