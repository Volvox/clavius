Template.keyboard.rendered = ->
  $keyboard = $('<ul></ul>')
  $('#keyboard').append $keyboard

  _.each [21..108], (note) -> # A0 to C8
    $key = $('<li></li>')
    if noteIsAccidental(note)
      $key.addClass 'accidental'
    $keyboard.append $key

  App.keyboard ?= new VirtualKeyboard
    noteOn: (note) ->
      App.instrument.noteOn note
      $($('#keyboard ul li').get(note - 21)).addClass 'active'
    noteOff: (note) ->
      App.instrument.noteOff note
      $($('#keyboard ul li').get(note - 21)).removeClass 'active'
