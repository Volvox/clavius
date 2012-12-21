class Drumkit extends Instrument
  constructor: (params) ->
    @output = audioContext.createGainNode()
    @rootNote = 60 # middle C
    @samples = []

  loadSample: (url, index) ->
    loader = new BufferLoader audioContext, [url], (bufferList) =>
      @samples[index] = bufferList[0]
    loader.load()

  loadSamples: (urls) ->
    loader = new BufferLoader audioContext, urls, (bufferList) =>
      @samples = bufferList
    loader.load()

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    note -= @rootNote
    if @samples[note]?
      source = audioContext.createBufferSource()
      source.buffer = @samples[note]
      source.connect @output
      source.start time

  noteOff: (note, time) ->
    false

drumkitDemo = ->
  drumkit = new Drumkit()
  drumkit.connect masterGainNode

  freesoundIds = [26885, 26887, 26900, 26902, 26896, 26889, 26879, 26880, 26881, 26883, 26884, 26878]
  for id, i in freesoundIds
    do (id, i) ->
      getFreesoundSample id, (sound) ->
        drumkit.loadSample sound['preview-hq-ogg'], i

  keyboard = new VirtualKeyboard
    noteOn: (note) ->
      console.log note
      drumkit.noteOn note
    noteOff: (note) ->
      drumkit.noteOff note

  drumkit
