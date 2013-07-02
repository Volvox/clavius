# based on https://github.com/cwilso/midi-synth/blob/master/js/synth.js

class @ProdigySynthesizer extends Instrument
  constructor: (@params) ->
    @output = App.audioContext.createGainNode()
    @voices = []

    # This is the "initial patch"
    @params ?=
      modWaveform: 0 # SINE
      modFrequency: 21 # Hz * 10 = 2.1
      modOscFreqMultiplier: 1
      modOsc1: 15
      modOsc2: 17
      osc1Waveform: 2 # SAW
      osc1Octave: 0 # 32'
      osc1Detune: 0 # 0
      osc1Mix: 50.0 # 50%
      osc2Waveform: 2 # SAW
      osc2Octave: 0 # 16'
      osc2Detune: -25 # fat detune makes pretty analogue-y sound.  :)
      osc2Mix: 50.0 # 0%
      filterCutoff: 19.0
      filterQ: 7.0
      filterMod: 21
      filterEnv: 56
      envA: 2
      envD: 15
      envS: 68
      envR: 5
      filterEnvA: 5
      filterEnvD: 6
      filterEnvS: 5
      filterEnvR: 7
      drive: 38
      rev: 32
      vol: 75
      pitchWheel: 0.0

  noteOn: (note, time) ->
    time ?= App.audioContext.currentTime
    unless @voices[note]?
      @voices[note] = new ProdigyVoice(note, @params)
      @voices[note].connect @output
      @voices[note].start time

  noteOff: (note, time) ->
    time ?= App.audioContext.currentTime
    if @voices[note]?
      @voices[note].stop time
      @voices[note] = null

class ProdigyVoice extends Voice
  constructor: (@note, @params, @velocity) ->
    @output = App.audioContext.createGainNode()
    @originalFrequency = noteToFrequency(note)

    # create osc 1
    @osc1 = App.audioContext.createOscillator()
    @updateOsc1Frequency()
    @osc1.type = @params.osc1Waveform
    @osc1Gain = App.audioContext.createGainNode()
    @osc1Gain.gain.value = 0.005 * @params.osc1Mix

    # this.gain.gain.value = 0.05 + (0.33 * velocity);
    @osc1.connect @osc1Gain

    # create osc 2
    @osc2 = App.audioContext.createOscillator()
    @updateOsc2Frequency()
    @osc2.type = @params.osc2Waveform
    @osc2Gain = App.audioContext.createGainNode()
    @osc2Gain.gain.value = 0.005 * @params.osc2Mix
    @osc2.connect @osc2Gain

    # create modulator osc
    @modOsc = App.audioContext.createOscillator()
    @modOsc.type = @params.modWaveform
    @modOsc.frequency.value = @params.modFrequency / 10 * @params.modOscFreqMultiplier
    @modOsc1Gain = App.audioContext.createGainNode()
    @modOsc.connect @modOsc1Gain
    @modOsc1Gain.gain.value = @params.modOsc1 / 10
    @modOsc1Gain.connect @osc1.frequency # tremolo
    @modOsc2Gain = App.audioContext.createGainNode()
    @modOsc.connect @modOsc2Gain
    @modOsc2Gain.gain.value = @params.modOsc2 / 10
    @modOsc2Gain.connect @osc2.frequency # tremolo

    # create the LP filter
    @filter1 = App.audioContext.createBiquadFilter()
    @filter1.type = @filter1.LOWPASS
    @filter1.Q.value = @params.filterQ
    @filter2 = App.audioContext.createBiquadFilter()
    @filter2.type = @filter2.LOWPASS
    @filter2.Q.value = @params.filterQ
    @osc1Gain.connect @filter1
    @osc2Gain.connect @filter1
    @filter1.connect @filter2

    # connect the modulator to the filters
    @modFilterGain = App.audioContext.createGainNode()
    @modOsc.connect @modFilterGain
    @modFilterGain.gain.value = @params.filterMod * 10
    @modFilterGain.connect @filter1.detune # filter tremolo
    @modFilterGain.connect @filter2.detune # filter tremolo

    # create the volume envelope
    @envelope = App.audioContext.createGainNode()
    @filter2.connect @envelope
    @envelope.connect @output

  start: (time) ->
    envAttackEnd = time + (@params.envA / 20.0)
    @envelope.gain.value = 0.0
    @envelope.gain.setValueAtTime 0.0, time
    @envelope.gain.linearRampToValueAtTime 1.0, envAttackEnd
    @envelope.gain.setTargetValueAtTime (@params.envS / 100.0), envAttackEnd, (@params.envD / 100.0) + 0.001
    pitchFrequency = @originalFrequency
    filterInitLevel = filterFrequencyFromCutoff(pitchFrequency, @params.filterCutoff / 100)
    filterAttackLevel = filterFrequencyFromCutoff(pitchFrequency, @params.filterCutoff / 100 + (@params.filterEnv / 120))
    filterSustainLevel = filterFrequencyFromCutoff(pitchFrequency, @params.filterCutoff / 100 + ((@params.filterEnv / 120) * (@params.filterEnvS / 100.0)))
    filterAttackEnd = time + (@params.filterEnvA / 20.0)

    @filter1.frequency.value = filterInitLevel
    @filter1.frequency.setValueAtTime filterInitLevel, time
    @filter1.frequency.linearRampToValueAtTime filterAttackLevel, filterAttackEnd
    @filter1.frequency.setTargetValueAtTime filterSustainLevel, filterAttackEnd, (@params.filterEnvD / 100.0)
    @filter2.frequency.value = filterInitLevel
    @filter2.frequency.setValueAtTime filterInitLevel, time
    @filter2.frequency.linearRampToValueAtTime filterAttackLevel, filterAttackEnd
    @filter2.frequency.setTargetValueAtTime filterSustainLevel, filterAttackEnd, (@params.filterEnvD / 100.0)

    # console.log "pitchFrequency: " + pitchFrequency + " filterInitLevel: " + filterInitLevel + " filterAttackLevel: " + filterAttackLevel + " filterSustainLevel: " + filterSustainLevel

    @osc1.start time
    @osc2.start time
    @modOsc.start time

  stop: (time) ->
    release = time + (@params.envR / 10.0)
    initFilter = filterFrequencyFromCutoff(@originalFrequency, @params.filterCutoff / 100 * (1.0 - (@params.filterEnv / 100.0)))

    # console.log "noteoff: time: " + time + " val: " + @filter1.frequency.value + " initF: " + initFilter + " fR: " + @params.filterEnvR / 100
    @envelope.gain.cancelScheduledValues time
    @envelope.gain.setValueAtTime @envelope.gain.value, time # this is necessary because of the linear ramp
    @envelope.gain.setTargetValueAtTime 0.0, time, (@params.envR / 100)
    @filter1.frequency.cancelScheduledValues time
    @filter1.frequency.setValueAtTime @filter1.frequency.value, time # this is necessary because of the linear ramp
    @filter1.frequency.setTargetValueAtTime initFilter, time, (@params.filterEnvR / 100.0)
    @filter2.frequency.cancelScheduledValues time
    @filter2.frequency.setValueAtTime @filter2.frequency.value, time # this is necessary because of the linear ramp
    @filter2.frequency.setTargetValueAtTime initFilter, time, (@params.filterEnvR / 100.0)
    @osc1.stop release
    @osc2.stop release

  updateOsc1Frequency: ->
    @osc1.frequency.value = (@originalFrequency * Math.pow(2, @params.osc1Octave - 2)) # -2 because osc1 is 32', 16', 8'
    @osc1.detune.value = @params.osc1Detune + @params.pitchWheel * 500 # value in cents - detune major fifth.

  updateOsc2Frequency: ->
    @osc2.frequency.value = (@originalFrequency * Math.pow(2, @params.osc2Octave - 1))
    @osc2.detune.value = @params.osc2Detune + @params.pitchWheel * 500 # value in cents - detune major fifth.
