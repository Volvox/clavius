Template.instruments.rendered = ->
  instrument = new Instrument()
  instrument.connect masterGainNode
  letters = "awsedrfgyhujkolp;['".split ''
  for letter, i in letters
    do (letter, i) ->
      Mousetrap.bind letter, ->
        console.log 60 + i
        instrument.playNote 60 + i # middle C
