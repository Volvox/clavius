Meteor.publish "clips", ->
  Clips.find()

Meteor.publish "songs", ->
  Songs.find()

Meteor.publish "presets", ->
  Presets.find()
