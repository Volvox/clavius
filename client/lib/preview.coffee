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

  render: (canvas, dotted) ->
    ctx = canvas.getContext '2d'
    start = 0
    end = Math.max (note.stop for note in @clip.notes)...
    length = end - start
    pitches = (note.sound for note in @clip.notes)
    noteMin = Math.min(pitches...)
    noteMax = Math.max(pitches...)
    tickWidth = canvas.width / length
    noteHeight = canvas.height / 16
    ctx.fillStyle = 'rgba(0, 0, 0, 0.4)'

    #mini dotted pattern on sequencer page (pattern_preview)
    if dotted?
      radius = noteHeight / 3.0
      for i in [0..16]
        for j in [0..16]
          ctx.fillStyle = 'rgba(255, 255, 255, 0.2)'
          ctx.beginPath()
          ctx.arc(i*noteHeight, j*noteHeight, radius, 0, 2 * Math.PI, false)
          ctx.fill()
      for note in @clip.notes
        tickLength = note.stop - note.start
        x = (note.start / length) * canvas.width
        y = ((sequencer.getRow note.sound) % 16) * (canvas.height / 16)
        ctx.fillStyle = '#fa435f'
        ctx.beginPath()
        ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
        ctx.fill()

    #rectangular horizontal pattern on mixer page
    else
      for note in @clip.notes
        ctx.fillRect note.start * tickWidth, (note.sound - noteMin) * noteHeight, (note.stop - note.start) * tickWidth, noteHeight


Meteor.startup ->
  window.previewers = {}

preloadPreview = (clip) ->
  if clip? and not previewers[clip._id]?
      previewers[clip._id] = new ClipPreview(clip)

getPreview = (clip) ->
  if clip?
    previewers[clip._id]
