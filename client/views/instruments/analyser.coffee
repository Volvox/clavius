class Analyser
  constructor: (params) ->
    @input = audioContext.createGainNode()
    @audioAnalyser = audioContext.createAnalyser()
    # Connect the stream to an analyser
    @input.connect @audioAnalyser

    params ?= {}

    @canvas = params.canvas
    @ctx = @canvas.getContext('2d')

    # must be a power of two and 2x size of the canvas.width
    if params.fftSize?
      @audioAnalyser.fftSize = params.fftSize
    else
      @audioAnalyser.fftSize = 1024

    # value from 0 -> 1 where 0 represents no time averaging with the last analysis frame.
    if params.smoothingTimeConstant?
      @audioAnalyser.smoothingTimeConstant = params.smoothingTimeConstant
    else
      @audioAnalyser.smoothingTimeConstant = 0

    # power value in the scaling range for the FFT analysis data for conversion to unsigned byte values.
    if params.minDecibels?
      @audioAnalyser.minDecibels = params.minDecibels
    if params.maxDecibels?
      @audioAnalyser.maxDecibels = params.maxDecibels

    if params.height?
      @canvas.height = params.height
    else
      @canvas.height = 128
    if params.width?
      @canvas.width = params.width
    else
      @canvas.width = @audioAnalyser.frequencyBinCount

    if params.get?
      switch params.get
        when 'float frequency' then @drawFF() #real-time frequency domain data
        when 'byte frequency' then @drawBF()  #real-time frequency domain data
        when 'time domain' then @drawTD()     #real-time waveform data
        when 'volume meter'                   #real-time signal strength for the L + R audio channel
          splitter = params.splitter
          @input.connect splitter
          splitter.connect @audioAnalyser, 0, 0
          @drawVU()
    else
      @drawBF()

  drawFF: =>
    @floatFrequency()
    requestAnimationFrame @drawFF

  floatFrequency: ->
    data = new Float32Array @audioAnalyser.frequencyBinCount
    @audioAnalyser.getFloatFrequencyData(data)

  drawBF: =>
    @byteFrequency()
    requestAnimationFrame @drawBF

  byteFrequency: ->
    data = new Uint8Array @audioAnalyser.frequencyBinCount
    @audioAnalyser.getByteFrequencyData(data)
    @ctx.fillStyle = "rgba(255,255,255,0.2)"
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
    @ctx.fillStyle = "#000"
    h = Math.floor((data.length*0.33) / @canvas.width)
    v = 0
    s = 0
    for i in [0...@canvas.width]
      v = data[i*h]
      s = (v/255) * @canvas.height
      @ctx.fillRect(i, (@canvas.height-s), 1, s)

  drawTD: =>
    @timeDomain()
    requestAnimationFrame @drawTD

  timeDomain: ->
    data = new Uint8Array @audioAnalyser.frequencyBinCount
    @audioAnalyser.getByteTimeDomainData(data)
    @ctx.fillStyle = 'rgba(255,255,255,0.2)'
    @ctx.fillRect 0,0,@canvas.width,@canvas.height
    @ctx.strokeStyle = 'rgba(200,0,0,0.5)'
    h = Math.floor( data.length / @canvas.width )
    v = 0
    s = 0
    @ctx.beginPath()
    @ctx.moveTo( 0, (data[0]/255) * @canvas.height )
    for i in [1...@canvas.width]
      v = data[i*h]
      s = (v/255) * @canvas.height
      @ctx.lineTo i, s
    @ctx.stroke()

  drawVU: =>
    @volumeMeter()
    requestAnimationFrame @drawVU

  volumeMeter: =>
    data = new Uint8Array @audioAnalyser.frequencyBinCount
    @audioAnalyser.getByteFrequencyData(data)
    average = @averageVolume(data)
    @ctx.clearRect(0,0,60,130)
    @ctx.fillStyle = "#000"
    @ctx.fillRect(0, 130-average, 25, 130)

  averageVolume: (data) ->
    vals = 0

    #get all the frequency amplitudes
    for i in [0...data.length]
      vals += data[i]
    average = vals / data.length
    average


# /demo/analyser
Template.analyser.rendered = ->

  synth = new SubtractiveSynthesizer
    filterEnvelopeEnabled: false
  synth.volumeEnvelope.setADSR 0.01, 0.2, 0.7, 0.5
  synth.filter.Q.value = 5.7

  keyboard = new VirtualKeyboard
    noteOn: (note) ->
      synth.noteOn note
    noteOff: (note) ->
      synth.noteOff note

  # not currently working
  # analyseFF = new Analyser
  #   canvas: @find('canvas#ff-analyser')
  #   get: 'float frequency'
  # synth.connect analyseFF.input

  analyseBF = new Analyser
    canvas: @find('#bf-analyser')
    get: 'byte frequency'
    width: 150
    height: 120
  synth.connect analyseBF.input

  analyseTD = new Analyser
    canvas: @find('#td-analyser')
    get: 'time domain'
    width: 150
    height: 120
  synth.connect analyseTD.input

  #volume meter needs two channels
  splitter = audioContext.createChannelSplitter()
  analyseVU_ch1 = new Analyser
    canvas: @find('#vu1-analyser')
    get: 'volume meter'
    smoothingTimeConstant: 0.3
    splitter: splitter
    width: 30
  analyseVU_ch2 = new Analyser
    canvas: @find('#vu2-analyser')
    get: 'volume meter'
    smoothingTimeConstant: 0.0
    splitter: splitter
    width: 30
  synth.connect analyseVU_ch1.input
  synth.connect analyseVU_ch2.input

  synth.connect masterGainNode

  $(@find('.filter-slider')).slider
    max: 18000
    min: 50
    slide: ( e, ui ) ->
      synth.filter.frequency.value = ui.value
      synth.filter.Q.value = ui.value