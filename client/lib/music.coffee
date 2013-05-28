noteToFrequency = (note) ->
  Math.pow(2, (note - 69) / 12) * 440.0

frequencyToNote = (frequency) ->
  12 * (Math.log(frequency / 440.0) / Math.log(2)) + 69

noteName = (note) ->
  noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
  noteNames[note % 12]

noteOctave = (note) ->
  Math.floor(note / 12) - 1

noteIsAccidental = (note) ->
  noteName(note).length == 2
