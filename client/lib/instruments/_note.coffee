class @Voice
  constructor: (@note, @velocity) ->
    @output = App.audioContext.createGain()

    @oscillator = App.audioContext.createOscillator()
    @amplifier = App.audioContext.createGain()

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
