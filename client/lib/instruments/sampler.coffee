class Sampler extends Instrument
  constructor: (params) ->
    @output = App.audioContext.createGainNode()
    @amplifier = App.audioContext.createGainNode()
    @filter = App.audioContext.createBiquadFilter()
    @volumeEnvelope = new ADSREnvelope(@amplifier.gain)

    params ?= {}
    @loop = params.loop ? false
    @offset = params.offset ? 0
    @duration = params.duration
    @filterEnvelopeEnabled = params.filterEnvelopeEnabled ? false
    @filterEnabled = params.filterEnabled ? false

    if @filterEnabled
      @finalNode = @filter
    else
      @finalNode = @amplifier

    if @filterEnvelopeEnabled
      @filterEnvelope = new ADSREnvelope(@filter.frequency)
      @filterEnvelope.max = @filter.frequency.value

    @filter.connect @amplifier
    @amplifier.connect @output

    @loadSample params.buffer ? params.url

  noteOn: (note, time) ->
    time ?= App.audioContext.currentTime
    if @sample?
      if not @loop or not @source?
        @source = App.audioContext.createBufferSource()
        @source.connect @finalNode
        @source.buffer = @sample
        @source.loop = @loop
        @source.start time, @offset, @duration
      @volumeEnvelope.start time
      if @filterEnvelopeEnabled
        @filterEnvelope.start time

  noteOff: (note, time) ->
    time ?= App.audioContext.currentTime
    @volumeEnvelope.stop time
    if @filterEnvelopeEnabled
      @filterEnvelope.stop time

  loadSample: (bufferOrUrl) ->
    if bufferOrUrl instanceof ArrayBuffer
      @sample = App.audioContext.createBuffer bufferOrUrl
    else
      loader = new BufferLoader App.audioContext, [bufferOrUrl], (bufferList) =>
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

samplerDemo = ->
  sampler = new Sampler
    url: "http://www.freesound.org/data/previews/24/24749_7037-hq.ogg"
    loop: on
    filterEnabled: yes
    filterEnvelopeEnabled: yes

  sampler.volumeEnvelope.setADSR 0.01, 0.2, 0.7, 0.5
  sampler.filterEnvelope.setADSR 0.05, 0.1, 0.9, 0.3
  sampler.filterEnvelope.max = 550
  sampler.filterEnvelope.min = 240
  sampler.filter.Q.value = 15
  sampler.connect App.masterGainNode

  keyboard = new VirtualKeyboard
    noteOn: ->
      sampler.noteOn 0
    noteOff: ->
      sampler.noteOff 0

  sampler

