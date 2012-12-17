class Instrument
  constructor: ->
    @output = audioContext.createGainNode()
    @oscillator = audioContext.createOscillator()
    @envelope = audioContext.createGainNode()
    @decay = 0.5

    @oscillator.connect @envelope
    @envelope.connect @output
    @envelope.gain.value = 0

    @oscillator.start(0)

  connect: (target) ->
    @output.connect target

  playFrequency: (frequency, time) ->
    noteTime = time or audioContext.currentTime
    @oscillator.frequency.setValueAtTime frequency, noteTime
    @envelope.gain.cancelScheduledValues(0)
    @envelope.gain.setValueAtTime 1.0, noteTime
    @envelope.gain.linearRampToValueAtTime 0, noteTime + @decay

  playNote: (note, time) ->
    @playFrequency noteToFrequency(note), time or 0

  playNotes: (notes) ->
    startTime = audioContext.currentTime + 0.005

    for note in notes
      contextStart = startTime + note.start
      @playNote note.sound, contextStart

  setGain: (gain) ->
    @output.gain.value = gain

noteToFrequency = (note) ->
  Math.pow(2, (note - 69) / 12) * 440.0

frequencyToNote = (frequency) ->
  12 * (Math.log(frequency / 440.0) / Math.log(2)) + 69

