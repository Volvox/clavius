class FMSynthesizer extends Instrument
  constructor: (modulationRatio, decay) ->
    @output = audioContext.createGainNode()
    @modulationRatio = modulationRatio or 0.162
    @decay = decay or 0.6

    @carrier = audioContext.createOscillator()
    @carrierGain = audioContext.createGainNode()
    @modulator = audioContext.createOscillator()
    @modulatorGain = audioContext.createGainNode()

    @modulator.connect @modulatorGain
    @modulatorGain.connect @carrier.frequency
    @carrier.connect @carrierGain
    @carrierGain.connect @output
    @carrierGain.gain.value = 0

    @setModulationDepth 100

    @carrier.start 0
    @modulator.start 0

  playFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @carrier.frequency.setValueAtTime frequency, noteTime
    @modulator.frequency.setValueAtTime @modulationRatio * frequency, noteTime
    @carrierGain.gain.cancelScheduledValues(0)
    @carrierGain.gain.setValueAtTime 1.0, noteTime
    @carrierGain.gain.setValueAtTime 0.0, noteTime + @decay

  setModulationDepth: (depth) ->
    @modulatorGain.gain.value = depth

