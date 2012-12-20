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
      if @source? then @noteOff 0
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
    @source.stop time
    @volumeEnvelope.stop time
    if @filterEnabled
      @filterEnvelope.stop time

  loadSample: (bufferOrUrl) ->
    if bufferOrUrl instanceof ArrayBuffer
      @sample = audioContext.createBuffer bufferOrUrl
    else
      console.log [bufferOrUrl]
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

