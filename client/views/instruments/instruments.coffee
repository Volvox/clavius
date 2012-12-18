Template.instruments.rendered = ->
  instruments = [new Instrument(), new AdditiveSynthesizer(), new FMSynthesizer()]
  instrument.connect masterGainNode for instrument in instruments
  current = 0

  Mousetrap.bind 'space', ->
    instruments[current].stop()
    current += 1
    current = 0 if current == instruments.length

  keyPressed = null
  letters = "awsedrfgyhujkolp;['".split ''
  for letter, i in letters
    do (letter, i) ->
      Mousetrap.bind letter, (->
        unless keyPressed is letter
          keyPressed = letter
          instruments[current].setNote 60 + i # middle C
          instruments[current].start()
      ), 'keydown'
      Mousetrap.bind letter, (->
        if keyPressed is letter
          keyPressed = null
          instruments[current].stop()
      ), 'keyup'
