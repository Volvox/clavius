Template.instruments.rendered = ->
  instruments = [new Instrument(), new AdditiveSynthesizer(), new FMSynthesizer()]
  instrument.connect masterGainNode for instrument in instruments
  current = 0

  Mousetrap.bind 'space', ->
    current += 1
    current = 0 if current == instruments.length

  letters = "awsedrfgyhujkolp;['".split ''
  for letter, i in letters
    do (letter, i) ->
      Mousetrap.bind letter, ->
        instruments[current].playNote 60 + i # middle C
