class @FMSynthesizer extends Instrument
  constructor: (params) ->
    params ?= {}
    @output = audioContext.createGain()
    @carrier = audioContext.createOscillator()
    @modulator = audioContext.createOscillator()
    @modulatorGain = audioContext.createGain()
    @amplifier = audioContext.createGain()

    @modulator.connect @modulatorGain
    @modulatorGain.connect @carrier.frequency
    @carrier.connect @amplifier
    @amplifier.connect @output

    @modulatorGain.gain.value = params.modulationDepth ? 100
    @modulationRatio = params.modulationRatio ? 1.618

    @amplifier.gain.value = 0
    @carrier.start 0
    @modulator.start 0

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    frequency = noteToFrequency note
    @carrier.frequency.setValueAtTime frequency, time
    @modulator.frequency.setValueAtTime @modulationRatio * frequency, time
    @amplifier.gain.setValueAtTime 1, time

  noteOff: (note, time) ->
    time ?= audioContext.currentTime
    @amplifier.gain.setValueAtTime 0, time
