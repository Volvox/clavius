class Analyser
    render: (canvas) ->
        @canvas = canvas
        @audioAnalyser = audioContext.createAnalyser()
        console.log @audioAnalyser
        @audioAnalyser.smoothingTimeConstant = 0.85
        @audioAnalyser.fftSize = 1024
        source = audioContext.createBufferSource()

        #Connect the stream to an analyser
        source.connect @audioAnalyser
        #connect analyzer to the speakers
        @audioAnalyser.connect audioContext.destination
        @draw()

    draw: ->
        requestAnimationFrame @draw @canvas
        @clear
        ctx = @canvas.getContext('2d')
        ctx.fillStyle = "black"
        freqByteData = new Uint8Array @audioAnalyser.frequencyBinCount
        @audioAnalyser.getByteFrequencyData freqByteData
        for i in [0...freqByteData.length]
            magnitude = freqByteData[i]
            ctx.fillRect(10*i, @canvas.height, 0, -magnitude)

    clear: ->
        ctx = @canvas.getContext '2d'
        ctx.clearRect 0, 0, @canvas.width, @canvas.height


Template.analyser.rendered = ->
    # unless window.analyser?
    canvas = @find('canvas#analyser')
    window.analyser = new Analyser()
    analyser.render(canvas)


    # getBuffer(@data).render(@find('canvas'))