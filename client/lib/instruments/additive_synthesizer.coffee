class @AdditiveSynthesizer extends Instrument
  constructor: (params) ->
    params ?= {}
    @output = audioContext.createGain()
    @ratios = params.ratios ? [0.56, 0.92, 1.19, 1.71, 2, 2.74, 3, 3.76, 4.07]
    @oscillators = (audioContext.createOscillator() for r in @ratios)
    @mixer = audioContext.createGain()
    @amplifier = audioContext.createGain()

    @mixer.gain.value = 1 / @oscillators.length

    oscillator.connect @mixer for oscillator in @oscillators
    @mixer.connect @amplifier
    @amplifier.connect @output

    @amplifier.gain.value = 0
    oscillator.start(0) for oscillator in @oscillators

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    frequency = noteToFrequency note
    oscillator.frequency.setValueAtTime(@ratios[i] * frequency, time) for oscillator, i in @oscillators
    @amplifier.gain.setValueAtTime 1, time

  noteOff: (note, time) ->
    time ?= audioContext.currentTime
    @amplifier.gain.setValueAtTime 0, time
