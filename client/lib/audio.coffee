playBuffer = (buffer, start, stop, effectsPipeline, playbackRate) ->
  source = audioContext.createBufferSource()
  source.buffer = buffer
  source.playbackRate.value = playbackRate if playbackRate?

  if effectsPipeline?
    source.connect effectsPipeline
    effectsPipeline.connect masterGainNode
  else
    source.connect masterGainNode

  source.start start
  source.stop stop if stop?

Meteor.startup ->
  window.audioContext = new webkitAudioContext()

  # support deprecated noteOn(), noteOff() methods
  for source in [audioContext.createBufferSource(), audioContext.createOscillator()]
    prototype = source.constructor.prototype
    unless prototype.start?
      prototype.start = prototype.noteOn
    unless prototype.stop?
      prototype.stop = prototype.noteOff

  if audioContext.createDynamicsCompressor
    compressor = audioContext.createDynamicsCompressor()
    compressor.connect(audioContext.destination)
    finalMixNode = compressor
  else
    finalMixNode = audioContext.destination

  window.masterGainNode = audioContext.createGainNode() # master volume
  masterGainNode.gain.value = 0.7 # reduce overall volume to avoid clipping
  masterGainNode.connect(finalMixNode)
