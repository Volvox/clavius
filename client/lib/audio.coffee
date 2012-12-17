playBuffer = (buffer, start, stop, effectsPipeline, playbackRate) ->
  source = audioContext.createBufferSource()
  source.buffer = buffer
  console.log("played")

  source.playbackRate.value = playbackRate if playbackRate?

  if effectsPipeline?
    source.connect effectsPipeline
    effectsPipeline.connect masterGainNode
  else
    source.connect masterGainNode

  source.noteOn start
  source.noteOff stop if stop?

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