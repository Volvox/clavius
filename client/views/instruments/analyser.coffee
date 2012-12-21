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
    @audioAnalyser.smoothingTimeConstant = 0

    # canvas
    @ctx = @canvas.getContext('2d')
    @canvas.height = 128
    @canvas.width = @audioAnalyser.frequencyBinCount #only ^2
    @draw()

  draw: =>
    @render()
    requestAnimationFrame @draw

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
  canvas = @find('canvas#analyser')
  analyser = new Analyser(canvas)
  synth = new SubtractiveSynthesizer
    filterEnvelopeEnabled: false

  synth.volumeEnvelope.setADSR 0.01, 0.2, 0.7, 0.5
  synth.filter.Q.value = 5.7

  synth.connect analyser.input
  synth.connect masterGainNode

  keyboard = new VirtualKeyboard
    noteOn: (note) ->
      synth.noteOn note
    noteOff: (note) ->
      synth.noteOff note


  $(@find('.filter-slider')).slider
    max: 18000
    min: 50
    slide: ( e, ui ) ->
      synth.filter.frequency.value = ui.value
