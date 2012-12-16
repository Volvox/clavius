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

  render: (canvas) ->
    ctx = canvas.getContext '2d'
    start = Math.min (note.start for note in @clip.notes)...
    end = Math.max (note.stop for note in @clip.notes)...
    length = end - start
    tickWidth = canvas.width / length
    noteHeight = canvas.height / @clip.sounds.length

    ctx.fillStyle = 'rgba(0, 0, 0, 0.4)'
    for note in @clip.notes
      ctx.fillRect note.start * tickWidth, note.sound * noteHeight, (note.stop - note.start) * tickWidth, noteHeight

