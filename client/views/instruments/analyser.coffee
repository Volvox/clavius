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
    window.subtractive = new SubtractiveSynthesizer()
    window.sampler = new Sampler
      loop: true
      filterEnabled: true
      filterEnvelopeEnabled: true
    sampler.volumeEnvelope.setADSR 0.09, 0.2, 0.1, 0.5
    sampler.filterEnvelope.setADSR 0.05, 0.1, 0.9, Math.random()*4000


    getFreesoundSample 60093, (url) ->
      sampler.loadSample url['preview-hq-ogg']
    fmSynth.modulatorGain.gain.value = 200
    # phaser = new tuna.Phaser()
    # sampler.filterEnvelopeEnabled = false
    # sampler.filter.frequency.value = 10000
    subtractive.filter.Q.value = 200
    keyboard = new VirtualKeyboard
      noteOn: (note) ->
        subtractive.noteOn note
      noteOff: (note) ->
        subtractive.noteOff note


    subtractive.connect analyser.input
    subtractive.connect masterGainNode
    console.log fmSynth
    # sampler.connect phaser.input
    # phaser.connect masterGainNode
    $(@find('.filter-slider')).slider
      max: 20000
      min: 0
      slide: ( e, ui ) ->
        console.log fmSynth
        subtractive.filter.frequency.setValueAtTime ui.value, audioContext.currentTime
        subtractive.filter.Q.value = ui.value
        #fmSynth.filter.Q.value = ui.value
        # phaser.stereoPhase.set ui.value