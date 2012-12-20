class Analyser
    constructor: (canvas) ->
        @canvas = canvas
        @audioAnalyser = audioContext.createAnalyser()
        @audioAnalyser.smoothingTimeConstant = 0.85
        @audioAnalyser.fftSize = 1024
        @source = audioContext.createBufferSource()
        @ctx = @canvas.getContext('2d')
        @canvas.height = 500
        @canvas.width = 500
        #Connect the stream to an analyser
        @source.connect @audioAnalyser
        #connect analyser to the speakers
        @audioAnalyser.connect audioContext.destination
        @draw()

    draw: ->
        @render()
        requestAnimationFrame @draw() #@canvas

    render: ->
        freqByteData = new Uint8Array @audioAnalyser.frequencyBinCount
        @audioAnalyser.getByteFrequencyData(freqByteData)
        @ctx.beginPath()
        @ctx.clearRect 0, 0, @canvas.width, @canvas.height
        @ctx.fillStyle = "#000"
        @ctx.fill()
        for i in [0...@audioAnalyser.frequencyBinCount]
            @ctx.fillRect(i*2, @canvas.height, 1, -freqByteData[i])


Template.analyser.rendered = ->
    # unless window.analyser?
    canvas = @find('canvas#analyser')
    window.analyser = new Analyser(canvas)