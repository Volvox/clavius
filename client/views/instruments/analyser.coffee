class Analyser
  constructor: (canvas) ->
    @canvas = canvas
    @input = audioContext.createGainNode()
    #buffer size, number of input channels (optional), number
    @audioAnalyser = audioContext.createAnalyser()

    # routing
    #Connect the stream to an analyser
    @input.connect @audioAnalyser

    # analyser properties
    @audioAnalyser.fftSize = 1024 #desired canv width * 2
    @audioAnalyser.smoothingTimeConstant = 0.75

    # canvas
    @ctx = @canvas.getContext('2d')
    @canvas.height = 128
    @canvas.width = @audioAnalyser.frequencyBinCount #only ^2
    @draw()

    #connect analyser to the speakers
    # @audioAnalyser.connect audioContext.destination

  draw: =>
    @render()
    requestAnimationFrame @draw #@canvas

  render: ->
    freqByteData = new Uint8Array @audioAnalyser.frequencyBinCount
    @audioAnalyser.getByteFrequencyData(freqByteData)
    @ctx.beginPath()
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    @ctx.fillStyle = "#000"
    @ctx.fill()
    @ctx.moveTo(i, @canvas.height-(@canvas.height*freqByteData[0]/256))
    for i in [1...@audioAnalyser.frequencyBinCount]
      @ctx.lineTo(i, @canvas.height-(@canvas.height*freqByteData[i]/256))
      @ctx.stroke()

  Template.analyser.rendered = ->
    # unless window.analyser?
    canvas = @find('canvas#analyser')
    window.analyser = new Analyser(canvas)
    window.fmSynth = new FMSynthesizer()
    window.sampler = new Sampler
      loop: true
      filterEnabled: true
      filterEnvelopeEnabled: true
    sampler.volumeEnvelope.setADSR 0.09, 0.2, 0.1, 0.5
    sampler.filterEnvelope.setADSR 0.05, 0.1, 0.9, Math.random()*4000


    getFreesoundSample 60093, (url) ->
      sampler.loadSample url['preview-hq-ogg']
    # fmSynth.modulatorGain.gain.value = 200
    # sampler.filterEnvelopeEnabled = false
    # sampler.filter.frequency.value = 10000
    keyboard = new VirtualKeyboard
      noteOn: (note) ->
        fmSynth.noteOn note
      noteOff: (note) ->
        fmSynth.noteOff note

    fmSynth.connect analyser.input
    # sampler.connect analyser.input
    # sampler.connect masterGainNode
    # sampler.connect phaser.input
    fmSynth.connect masterGainNode
    $(@find('.filter-slider')).slider
      max: 10
      min: 0
      slide: ( e, ui ) ->
        # sampler.filter.frequency.setValueAtTime ui.value, audioContext.currentTime
        fmSynth.modulationRatio.gain.value = ui.value