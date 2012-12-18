Meteor.startup ->
  if Clips.find().count() > 0 and Songs.find().count() is 0
    Songs.insert
      tracks: [
        clips: [
          start: 0
          stop: 250
          data: Clips.findOne()
        ]
      ]
