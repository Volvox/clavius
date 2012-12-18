class AdditiveSynthesizer extends Instrument
  constructor: (ratios, envelope) ->
    @output = audioContext.createGainNode()
    @ratios = ratios or [0.56, 0.92, 1.19, 1.71, 2, 2.74, 3, 3.76, 4.07]
    @oscillators = (audioContext.createOscillator() for r in @ratios)
    @mixer = audioContext.createGainNode()
    @envelope = envelope or new ADSREnvelope(0.003, 0.3, 0.9, 1.3)

    @mixer.gain.value = 1 / @oscillators.length

    oscillator.connect @mixer for oscillator in @oscillators
    @mixer.connect @envelope.input
    @envelope.connect @output

    oscillator.start(0) for oscillator in @oscillators

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    oscillator.frequency.setValueAtTime(@ratios[i] * frequency, noteTime) for oscillator, i in @oscillators
