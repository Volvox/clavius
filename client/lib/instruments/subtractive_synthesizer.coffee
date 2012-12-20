class SubtractiveSynthesizer extends Instrument
  constructor: (params) ->
    params ?= {}
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @lowpass = audioContext.createBiquadFilter()
    @amplifier = audioContext.createGainNode()

    #remove upper harmonic content
    @cutoff = params.cutoff ? 300

    @oscillator.type = @oscillator.SAWTOOTH
    @lowpass.frequency.value = @cutoff

   # Controls how peaked the response will be at the cutoff frequency.
   # A large value makes the response more peaked.
   # resonance value in decibels.
    @lowpass.Q.value = params.Q ?
    @oscillator.connect @lowpass
    @lowpass.connect @amplifier
    @amplifier.connect @output

    @amplifier.gain.value = 0
    @oscillator.start 0

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    frequency = noteToFrequency note
    @oscillator.frequency.setValueAtTime frequency, time
    @amplifier.gain.setValueAtTime 1, time

  noteOff: (note, time) ->
    time ?= audioContext.currentTime
    @amplifier.gain.setValueAtTime 0, time