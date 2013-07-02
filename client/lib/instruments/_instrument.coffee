class @Instrument
  constructor: ->
    @output = App.audioContext.createGainNode()
    @voices = []

  noteOn: (note, time) ->
    time ?= App.audioContext.currentTime
    unless @voices[note]?
      @voices[note] = new Voice(note)
      @voices[note].connect @output
      @voices[note].start time

  noteOff: (note, time) ->
    time ?= App.audioContext.currentTime
    if @voices[note]?
      @voices[note].stop time
      @voices[note] = null

  export: ->
    console.log 'override in subclass'
    instrument: 'instrument'
    params: {}

  connect: (target) ->
    @output.connect target

  disconnect: ->
    @output.disconnect()

  playNotes: (notes) ->
    startTime = App.audioContext.currentTime + 0.005
    for note in notes
      @noteOn note.sound, startTime + note.start
      @noteOff note.sound, startTime + note.stop

  setGain: (gain) ->
    @output.gain.value = gain

@filterFrequencyFromCutoff = (pitch, cutoff) ->
  nyquist = 0.5 * App.audioContext.sampleRate
  filterFrequency = Math.pow(2, (9 * cutoff) - 1) * pitch
  if filterFrequency > nyquist
    filterFrequency = nyquist
  filterFrequency

@restorePreset = (preset) ->
  instruments =
    'drumkit': Drumkit
    'prodigy': ProdigySynthesizer
  new instruments[preset.instrument](preset.params)

