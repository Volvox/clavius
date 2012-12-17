Songs = new Meteor.Collection('songs')

Meteor.methods
  createSong: (data) ->
    data = data or {}
    if data.tracks?
      Songs.insert data
    null
