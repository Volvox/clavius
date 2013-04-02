class Voice
  constructor: (@note, @velocity) ->
    @output = audioContext.createGainNode()

    @oscillator = audioContext.createOscillator()
    @amplifier = audioContext.createGainNode()

    @oscillator.frequency.value = noteToFrequency @note
    @amplifier.gain.value = 0.2

    @oscillator.connect @amplifier
    @amplifier.connect @output

  start: (time) ->
    console.log 'override in subclass'
    @oscillator.start time

  stop: (time) ->
    console.log 'override in subclass'
    @oscillator.stop time

  connect: (target) ->
    @output.connect target

  disconnect: ->
    @output.disconnect()
