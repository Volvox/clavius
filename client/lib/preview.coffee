class ClipPreview
  constructor: (clip) ->
    @clip = clip
    @instrument = new SubtractiveSynthesizer()
    @instrument.connect masterGainNode

  play: ->
    startTime = audioContext.currentTime
    for note in @clip.notes
      noteStart = startTime + note.start
      noteStop = startTime + note.stop
      @instrument.setNote note.sound, noteStop
      @instrument.start noteStart
      @instrument.stop noteStop

  stop: ->
    @instrument.stop 0

  render: (canvas) ->
    ctx = canvas.getContext '2d'
    start = 0
    end = Math.max (note.stop for note in @clip.notes)...
    length = end - start
    pitches = (note.sound for note in @clip.notes)
    noteMin = Math.min(pitches...)
    noteMax = Math.max(pitches...)
    tickWidth = canvas.width / length
    noteHeight = canvas.height / (noteMax - noteMin)
    ctx.fillStyle = 'rgba(0, 0, 0, 0.4)'
    for note in @clip.notes
      ctx.fillRect note.start * tickWidth, (note.sound - noteMin) * noteHeight, (note.stop - note.start) * tickWidth, noteHeight

Meteor.startup ->
  window.previewers = {}

preloadPreview = (clip) ->
  unless previewers[clip._id]?
    previewers[clip._id] = new ClipPreview(clip)

getPreview = (clip) ->
  previewers[clip._id]
