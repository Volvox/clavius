class @Metronome
  constructor: ->
    @beatCount = 0
    @lastBeat = App.audioContext.currentTime
    unless Session.get('bpm')?
      Session.set 'bpm', 120

  bpm: ->
    Session.get 'bpm'

  bps: ->
    @bpm() / 60

  spb: ->
    1 / @bps()

  beat: (offset) ->
    @updateLast()
    @lastBeat + offset * @spb()

  measure: (offset) ->
    @updateLast()
    beatsSinceLast = @beatCount % 4
    lastMeasure = @lastBeat - (beatsSinceLast * @spb())
    lastMeasure + offset * (4 * @spb())

  updateLast: ->
    while App.audioContext.currentTime - @lastBeat > @spb()
      @beatCount += 1
      @lastBeat += @spb()

@noteToFrequency = (note) ->
  Math.pow(2, (note - 69) / 12) * 440.0

@frequencyToNote = (frequency) ->
  12 * (Math.log(frequency / 440.0) / Math.log(2)) + 69

@noteName = (note) ->
  noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
  noteNames[note % 12]

@noteOctave = (note) ->
  Math.floor(note / 12) - 1

@noteIsAccidental = (note) ->
  noteName(note).length == 2
