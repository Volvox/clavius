Clips = new Meteor.Collection('clips')

Meteor.methods
  createClip: (data) ->
    data = data or {}
    if data.notes?
      Clips.insert data
    null

