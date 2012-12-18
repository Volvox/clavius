Template.instruments.rendered = ->
  instruments = [new Instrument(), new AdditiveSynthesizer(), new FMSynthesizer(), new SubtractiveSynthesizer()]
  instrument.connect masterGainNode for instrument in instruments
  currentInstrument = 0
  currentNote = 60 # middle C

  Mousetrap.bind 'space', ->
    instruments[currentInstrument].stop()
    currentInstrument += 1
    currentInstrument = 0 if currentInstrument == instruments.length

  Mousetrap.bind 'z', ->
    # shift one octave down
    currentNote -= 12

  Mousetrap.bind 'x', ->
    # shift one octave up
    currentNote += 12

  keyPressed = null
  letters = "awsedrfgyhujkolp;['".split ''
  for letter, i in letters
    do (letter, i) ->
      Mousetrap.bind letter, (->
        unless keyPressed is letter
          keyPressed = letter
          instruments[currentInstrument].setNote currentNote + i
          instruments[currentInstrument].start()
      ), 'keydown'
      Mousetrap.bind letter, (->
        if keyPressed is letter
          keyPressed = null
          instruments[currentInstrument].stop()
      ), 'keyup'
