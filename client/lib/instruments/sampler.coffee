class Sampler extends Instrument
  constructor: (params) ->
    @output = audioContext.createGainNode()
    @amplifier = audioContext.createGainNode()
    @filter = audioContext.createBiquadFilter()
    @volumeEnvelope = new ADSREnvelope(@amplifier.gain)
    @filterEnvelope = new ADSREnvelope(@filter.frequency)
    @filterEnvelope.max = @filter.frequency.value

    params ?= {}
    @loop = params.loop ? false
    @offset = params.offset ? 0
    @duration = params.duration
    @filterEnabled = params.filterEnabled ? false

    if @filterEnabled
      @finalNode = @filter
    else
      @finalNode = @amplifier

    @filter.connect @amplifier
    @amplifier.connect @output

    @loadSample params.buffer ? params.url

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    if @sample?
      if not @loop or not @source?
        @source = audioContext.createBufferSource()
        @source.connect @finalNode
        @source.buffer = @sample
        @source.loop = @loop
        @source.start time, @offset, @duration
      @volumeEnvelope.start time
      if @filterEnabled
        @filterEnvelope.start time

  noteOff: (note, time) ->
    time ?= audioContext.currentTime
    @volumeEnvelope.stop time
    if @filterEnabled
      @filterEnvelope.stop time

  loadSample: (bufferOrUrl) ->
    if bufferOrUrl instanceof ArrayBuffer
      @sample = audioContext.createBuffer bufferOrUrl
    else
      loader = new BufferLoader audioContext, [bufferOrUrl], (bufferList) =>
        @sample = bufferList[0]
        @duration = @sample.duration - @offset unless @duration?
      loader.load()

  toggleFilter: ->
    @filterEnabled = !@filterEnabled
    if @filterEnabled
      @finalNode = @filter
    else
      @finalNode = @amplifier
    if @source?
      @source.disconnect()
      @source.connect @finalNode

getFreesoundSample = (soundId, callback) ->
  $.ajax
    url: "http://www.freesound.org/api/sounds/#{soundId}?api_key=ec0c281cc7404d14b6f5216f96b8cd7c"
    dataType: "jsonp"
    error: (e) ->
      console.log(e)
    success: (data) =>
      callback data

samplerDemo = ->
  sampler = new Sampler
    url: "http://www.freesound.org/data/previews/24/24749_7037-hq.ogg"
    loop: on
    filterEnabled: yes

  sampler.connect masterGainNode

  sampler.volumeEnvelope.setADSR 0.01, 0.2, 0.7, 0.5
  sampler.filterEnvelope.setADSR 0.05, 0.1, 0.9, 0.3
  sampler.filterEnvelope.max = 660
  sampler.filterEnvelope.min = 120
  sampler.filter.Q.value = 32

  keyboard = new VirtualKeyboard
    noteOn: ->
      sampler.noteOn 0
    noteOff: ->
      sampler.noteOff 0
  return sampler

