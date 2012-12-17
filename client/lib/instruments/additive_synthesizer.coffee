class AdditiveSynthesizer extends Instrument
  constructor: (waveType, detune, decay) ->
    @output = audioContext.createGainNode()
    @osc1 = audioContext.createOscillator()
    @osc2 = audioContext.createOscillator()
    @envelope = audioContext.createGainNode()
    @decay = decay or 0.3
    @detune = detune or 0.99

    @osc1.type = waveType or @osc1.SAWTOOTH
    @osc2.type = waveType or @osc2.SAWTOOTH

    @osc1.connect @envelope
    @osc2.connect @envelope
    @envelope.connect @output
    @envelope.gain.value = 0

    @osc1.start(0)
    @osc2.start(0)

  playFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @osc1.frequency.setValueAtTime frequency, noteTime
    @osc2.frequency.setValueAtTime @detune * frequency, noteTime
    @envelope.gain.cancelScheduledValues(0)
    @envelope.gain.setValueAtTime 0.5, noteTime
    @envelope.gain.linearRampToValueAtTime 0, noteTime + @decay
