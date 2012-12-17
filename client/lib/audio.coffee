playBuffer = (buffer, start, stop, effectsPipeline) ->
  source = audioContext.createBufferSource()
  source.buffer = buffer

  if effectsPipeline?
    source.connect effectsPipeline
    effectsPipeline.connect masterGainNode
  else
    source.connect masterGainNode

  source.start start
  source.stop stop if stop?

Meteor.startup ->
  window.audioContext = new webkitAudioContext()
  if audioContext.createDynamicsCompressor
    compressor = audioContext.createDynamicsCompressor()
    compressor.connect(audioContext.destination)
    finalMixNode = compressor
  else
    finalMixNode = audioContext.destination

  window.masterGainNode = audioContext.createGainNode() # master volume
  masterGainNode.gain.value = 0.7 # reduce overall volume to avoid clipping
  masterGainNode.connect(finalMixNode)

