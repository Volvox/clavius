class ClipPreview
  constructor: (clip) ->
    @clip = clip
    @soundbank = []
    for sound in @clip.sounds
      @soundbank.push new Audio(sound['preview-hq-ogg'])

  playNote: (i) =>
    note = @clip.notes[i]
    @soundbank[note.sound].currentTime = 0
    @soundbank[note.sound].play()
    if i < @clip.notes.length - 1
      next = @clip.notes[i+1].start - note.start
      if next == 0
        @playNote(i+1)
      else
        playNext = =>
          @playNote(i+1)
        @ticker = Meteor.setTimeout(playNext, next)

  play: ->
    @playNote(0)

  stop: ->
    Meteor.clearTimeout @ticker
