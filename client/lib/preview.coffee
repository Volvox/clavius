class ClipPreview
  constructor: (clip) ->
    @clip = clip
    @loadSounds()
    @gainNode = audioContext.createGainNode()
    @gainNode.gain.value = 0.7

  loadSounds: ->
    loader = new BufferLoader audioContext, (sound['preview-hq-ogg'] for sound in @clip.sounds), (bufferList) =>
      @soundbank = bufferList
    loader.load()

  play: =>
    if @soundbank?
      startTime = audioContext.currentTime
      for note in @clip.notes
        console.log(note)
        contextStart = startTime + note.start
        contextStop = startTime + note.stop
        playBuffer @soundbank[note.sound], contextStart, null, @gainNode
    else
      Meteor.setTimeout @play, 100

  stop: ->
    @gainNode.gain.value = 0.0

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


  # renderMini: (canvas) ->
  #   ctx = canvas.getContext '2d'
  #   start = Math.min (note.start for note in @clip.notes)...
  #   end = Math.max (note.stop for note in @clip.notes)...
  #   length = 100
  #   tickWidth = canvas.width / length
  #   noteHeight = canvas.height / @clip.sounds.length
  #   ctx.fillStyle = 'rgba(0, 0, 0, 0.4)'
  #   radius = 2
  #   for note in @clip.notes
  #     ctx.beginPath()
  #     ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
  #     ctx.fill()
  #     # ctx.fillRect note.start * tickWidth, note.sound * noteHeight, (note.stop - note.start) * tickWidth, noteHeight

Meteor.startup ->
  window.previewers = {}

preloadPreview = (clip) ->
  unless previewers[clip._id]?
    previewers[clip._id] = new ClipPreview(clip)

getPreview = (clip) ->
  previewers[clip._id]
