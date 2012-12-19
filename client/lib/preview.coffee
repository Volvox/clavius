class ClipPreview
  constructor: (clip) ->
    @clip = clip
    @instrument = new Polyphonic(SubtractiveSynthesizer, cutoff: 360)
    @instrument.connect masterGainNode

  play: ->
    startTime = audioContext.currentTime
    for note in @clip.notes
      @instrument.noteOn note.sound, startTime + note.start
      @instrument.noteOff note.sound, startTime + note.stop

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
