class AdditiveSynthesizer extends Instrument
  constructor: (waveType, detune, envelope) ->
    @output = audioContext.createGainNode()
    @osc1 = audioContext.createOscillator()
    @osc2 = audioContext.createOscillator()
    @envelope = envelope or new ADSREnvelope(0.01, 0.4, 0.7, 0.2)
    @detune = detune or 0.99

    @osc1.type = waveType or @osc1.SAWTOOTH
    @osc2.type = waveType or @osc2.SAWTOOTH

    @osc1.connect @envelope.input
    @osc2.connect @envelope.input
    @envelope.connect @output

    @osc1.start 0
    @osc2.start 0

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @osc1.frequency.setValueAtTime frequency, noteTime
    @osc2.frequency.setValueAtTime @detune * frequency, noteTime
