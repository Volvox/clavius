Template.clip_list.clips = ->
  Clips.find()

Template.clip_list.events
  'click ul#clips': (e) ->
    # get object from collection with the corresponding _id
    clipObject = Clips.findOne( _id: $(e.srcElement).attr('id') )
    clipPreview = new ClipPreview(clipObject)
    clipPreview.play()

