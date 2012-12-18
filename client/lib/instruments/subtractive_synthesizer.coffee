class SubtractiveSynthesizer extends Instrument
  constructor: (cutoff, envelope) ->
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @envelope = envelope or new ADSREnvelope(0.009, 0.2, 0.9, 0.7)
    @lowpass = audioContext.createBiquadFilter()
    @cutoff = cutoff or 300

    @oscillator.type = @oscillator.SAWTOOTH
    @lowpass.frequency.value = @cutoff

    @oscillator.connect @lowpass
    @lowpass.connect @envelope.input
    @envelope.connect @output

    @oscillator.start 0

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @oscillator.frequency.setValueAtTime frequency, noteTime

