Clips = new Meteor.Collection('clips')
Songs = new Meteor.Collection('songs')

Meteor.methods
  createClip: (data) ->
    data = data or {}
    if data.notes? and data.sounds?
      Clips.insert data
    null

  createSong: (data) ->
    data = data or {}
    if data.tracks?
      Songs.insert data
    null