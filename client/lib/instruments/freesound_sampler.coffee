class FreesoundSampler extends Instrument
  constructor: (params) ->
    params ?= {}
    @output = audioContext.createGainNode()
    @samples = @loadPack params.packId ? 7417

  loadPack: (packId) ->
    @samples = []
    $.ajax
      url: "http://www.freesound.org/api/packs/#{packId}/sounds?api_key=ec0c281cc7404d14b6f5216f96b8cd7c"
      dataType: "jsonp"
      error: (e) ->
        console.log(e)
      success: (data) =>
        @sounds = data.sounds
        loader = new BufferLoader audioContext, (sound['preview-hq-ogg'] for sound in @sounds), (bufferList) =>
          @samples = bufferList
        loader.load()

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    note = frequencyToNote(frequency) - 35 # general midi percussion mapping
    if @samples[note]?
      source = audioContext.createBufferSource()
      source.buffer = @samples[note]
      source.connect @output
      source.start noteTime

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    note -= 35 # general midi percussion mapping
    if @samples[note]?
      source = audioContext.createBufferSource()
      source.buffer = @samples[note]
      source.connect @output
      source.start noteTime

  noteOff: (note, time) ->
    false
