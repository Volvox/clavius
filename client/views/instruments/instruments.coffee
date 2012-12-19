Template.instruments.rendered = ->
  instrumentTypes = [Instrument, AdditiveSynthesizer, FMSynthesizer, SubtractiveSynthesizer]
  currentInstrument = -1
  instrument = null

  switchInstrument = ->
    instrument.disconnect() if instrument?
    currentInstrument += 1
    currentInstrument = 0 if currentInstrument == instrumentTypes.length
    instrument = new Polyphonic(instrumentTypes[currentInstrument])
    instrument.connect masterGainNode

  switchInstrument()

  keyboard = new VirtualKeyboard
    noteOn: (note) ->
      instrument.noteOn note, 0
    noteOff: (note) ->
      instrument.noteOff note, 0

  Mousetrap.bind 'space', ->
    switchInstrument()

