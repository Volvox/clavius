Template.clip_list.clips = ->
  Clips.find()

Template.clip_list.events
  'click ul#clips': (e) ->
    # get object from collection with the corresponding _id
    clipObject = Clips.findOne( _id: $(e.srcElement).data('id') )
    clipPreview = new ClipPreview(clipObject)

    #Todo: add &#9998 symbol next to pattern title
    $(e.srcElement).addClass('selected')
    sequencer.seed(clipObject)

    # 'click #update': (e) ->
    #     db.collection.update( <query>, <update>, <options> )