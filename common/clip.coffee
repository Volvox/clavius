@Clips = new Meteor.Collection('clips')

Meteor.methods
  createClip: (data) ->
    data ?= {}
    if data.notes?
      Clips.insert data
      null
