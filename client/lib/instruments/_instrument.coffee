class Instrument
  constructor: ->
    @output = audioContext.createGainNode()

    @oscillator = audioContext.createOscillator()
    @amplifier = audioContext.createGainNode()

    @oscillator.connect @amplifier
    @amplifier.connect @output

    @amplifier.gain.value = 0
    @oscillator.start 0

  noteOn: (note, time) ->
    console.log 'override in subclass'
    time ?= audioContext.currentTime
    @oscillator.frequency.setValueAtTime noteToFrequency(note), time
    @amplifier.gain.setValueAtTime 1, time

  noteOff: (note, time) ->
    console.log 'override in subclass'
    time ?= audioContext.currentTime
    @amplifier.gain.setValueAtTime 0, time

  export: ->
    console.log 'override in subclass'
    instrument: 'instrument'
    params: {}

  connect: (target) ->
    @output.connect target

  disconnect: ->
    @output.disconnect()

  playNotes: (notes) ->
    startTime = audioContext.currentTime + 0.005
    for note in notes
      @noteOn note.sound, startTime + note.start
      @noteOff note.sound, startTime + note.stop

  setGain: (gain) ->
    @output.gain.value = gain

class Polyphonic extends Instrument
  # turns any monophonic instrument into a polyphonic instrument
  constructor: (instrumentClass, params, numVoices) ->
    @output = audioContext.createGainNode()
    @mixer = audioContext.createGainNode()
    @voices = (new instrumentClass(params ? {}) for i in [1..(numVoices ? 12)])

    @mixer.gain.value = 0.3
    voice.connect @mixer for voice in @voices
    @mixer.connect @output

  noteOn: (note, time) ->
    time ?= audioContext.currentTime
    @voices[note % @voices.length].noteOn note, time

  noteOff: (note, time) ->
    @voices[note % @voices.length].noteOff note, time

noteToFrequency = (note) ->
  Math.pow(2, (note - 69) / 12) * 440.0

frequencyToNote = (frequency) ->
  12 * (Math.log(frequency / 440.0) / Math.log(2)) + 69

restorePreset = (preset) ->
  instruments =
    'drumkit': Drumkit
  new instruments[preset.instrument](preset.params)

