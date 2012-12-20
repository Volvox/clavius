class SubtractiveSynthesizer extends Instrument
  constructor: (params) ->
    params ?= {}
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @filter = audioContext.createBiquadFilter()
    @amplifier = audioContext.createGainNode()


    #remove upper harmonic content
    @cutoff = params.cutoff ? 300
    @filterEnvelope = new ADSREnvelope(@filter.frequency)
    @volumeEnvelope = new ADSREnvelope(@amplifier.gain)
    @oscillator.type = @oscillator.SAWTOOTH
    @filterEnvelope.max = @filter.frequency.value

   # Controls how peaked the response will be at the cutoff frequency.
   # A large value makes the response more peaked.
   # resonance value in decibels.
    @lowpass.Q.value = params.Q ?
    @oscillator.connect @lowpass
    @lowpass.connect @amplifier
    @oscillator.connect @filter
    @filter.connect @amplifier
    @amplifier.connect @output
    @oscillator.start 0

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    frequency = noteToFrequency note
    @oscillator.frequency.setValueAtTime frequency, time
    @volumeEnvelope.start time
    @filterEnvelope.start time

  noteOff: (note, time) ->
    time ?= audioContext.currentTime
    @amplifier.gain.setValueAtTime 0, time
    @volumeEnvelope.stop time
    @filterEnvelope.stop time

subSynthDemo = ->
  subSynth = new SubtractiveSynthesizer

  subSynth.volumeEnvelope.setADSR 0.01, 0.2, 0.7, 0.5
  subSynth.filterEnvelope.setADSR 0.003, 0.1, 0.4, 0.4
  subSynth.filterEnvelope.max = 10000
  subSynth.filterEnvelope.min = 42
  subSynth.filter.Q.value = 5.7

  subSynth.connect masterGainNode

  keyboard = new VirtualKeyboard
    noteOn: (note) ->
      subSynth.noteOn note
    noteOff: (note) ->
      subSynth.noteOff note

  subSynth

