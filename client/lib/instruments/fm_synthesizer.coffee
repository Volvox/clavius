class FMSynthesizer extends Instrument
  constructor: (modulationRatio, envelope) ->
    @output = audioContext.createGainNode()
    @modulationRatio = modulationRatio or 0.162

    @carrier = audioContext.createOscillator()
    @modulator = audioContext.createOscillator()
    @modulatorGain = audioContext.createGainNode()
    @envelope = envelope or new ADSREnvelope(0.01, 0.4, 0.7, 0.2)

    @modulator.connect @modulatorGain
    @modulatorGain.connect @carrier.frequency
    @carrier.connect @envelope.input
    @envelope.connect @output

    @setModulationDepth 100

    @carrier.start 0
    @modulator.start 0

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @carrier.frequency.setValueAtTime frequency, noteTime
    @modulator.frequency.setValueAtTime @modulationRatio * frequency, noteTime

  setModulationDepth: (depth) ->
    @modulatorGain.gain.value = depth

