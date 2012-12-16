Clips = new Meteor.Collection('clips')

Meteor.methods
  createClip: (data) ->
    data = data or {}
    if data.notes? and data.sounds?
      Clips.insert data
    null