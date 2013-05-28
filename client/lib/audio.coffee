playBuffer = (buffer, start, stop, effectsPipeline, playbackRate) ->
  source = App.audioContext.createBufferSource()
  source.buffer = buffer
  source.playbackRate.value = playbackRate if playbackRate?
  if App.effectsPipeline?
    source.connect App.effectsPipeline
    App.effectsPipeline.connect App.masterGainNode
  else
    source.connect App.masterGainNode

  source.start start
  source.stop stop if stop?

setInstrument = (instrument) ->
  if App.instrument?
    App.instrument.disconnect()
  App.instrument = instrument
  App.instrument.connect App.masterGainNode

Meteor.startup ->
  App.audioContext = new webkitAudioContext()
  App.tuna = new Tuna(App.audioContext)
  App.effectsPipeline = new EffectsPipeline()
  App.metronome = new Metronome()

  # support deprecated noteOn(), noteOff() methods
  for source in [App.audioContext.createBufferSource(), App.audioContext.createOscillator()]
    prototype = source.constructor.prototype
    unless prototype.start?
      prototype.start = prototype.noteOn
    unless prototype.stop?
      prototype.stop = prototype.noteOff

  finalMixNode = App.audioContext.destination
  App.masterGainNode = App.audioContext.createGainNode() # master volume
  App.masterGainNode.gain.value = 0.7 # reduce overall volume to avoid clipping
  App.masterGainNode.connect(App.effectsPipeline.input)
  App.effectsPipeline.connect(finalMixNode)

