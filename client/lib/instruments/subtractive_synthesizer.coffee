class SubtractiveSynthesizer extends Instrument
  constructor: (waveType, detune, envelope) ->
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @envelope = envelope or new ADSREnvelope(0.1, 0.2, 0.7, 0.1)
    @lowpass = audioContext.createBiquadFilter()

    @oscillator.type = waveType or @oscillator.SQUARE
    @lowpass.frequency.value = 300

    @oscillator.connect @lowpass
    @lowpass.connect @envelope.input
    @envelope.connect @output

    @oscillator.start 0

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @oscillator.frequency.setValueAtTime frequency, noteTime

