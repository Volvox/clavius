class Instrument
  constructor: ->
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @envelope = new ADSREnvelope(0.01, 0.4, 0.7, 0.2)

    @oscillator.connect @envelope.input
    @envelope.connect @output

    @oscillator.start 0

  connect: (target) ->
    @output.connect target

  setFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @oscillator.frequency.setValueAtTime frequency, noteTime

  setNote: (note, time) ->
    @setFrequency noteToFrequency(note), time

  playFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @setFrequency frequency, time
    @start noteTime
    @stop noteTime

  playNote: (note, time) ->
    @playFrequency noteToFrequency(note), time

  playNotes: (notes) ->
    startTime = audioContext.currentTime + 0.005

    for note in notes
      contextStart = startTime + note.start
      @playNote note.sound, contextStart

  start: (time) ->
    noteTime = time or audioContext.currentTime
    @envelope.start noteTime

  stop: (time) ->
    noteTime = time or audioContext.currentTime
    @envelope.stop noteTime

  setGain: (gain) ->
    @output.gain.value = gain

noteToFrequency = (note) ->
  Math.pow(2, (note - 69) / 12) * 440.0

frequencyToNote = (frequency) ->
  12 * (Math.log(frequency / 440.0) / Math.log(2)) + 69
