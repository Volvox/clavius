typingTimer = null
checkInterval = 200

fetchResults = ->
  query = $('#freesound-search input').val()
  searchFreesound q: query, f: 'duration:[0.3 TO 5]' , (results) ->
    Session.set 'search_results', results

drawWaveform = (buffer, canvas, color) ->
  ctx = canvas.getContext '2d'
  width = canvas.width
  height = canvas.height
  ctx.fillStyle = color ? 'rgba(0, 0, 255, 0.4)'
  data = buffer.getChannelData(0)
  interpolation = buffer.length / width
  interpolated = (data[Math.floor(interpolation * i)] for i in [0...width])
  max = Math.max(interpolated...)
  scale = 1 / max
  ctx.beginPath()
  for value, i in interpolated
    value *= scale
    normalized = (height / 2) + (height / 2) * value
    ctx.lineTo i, normalized
  ctx.fill()

convertIndex = (index) ->
  row = Math.floor((11 - index) / 3)
  col = index % 3
  row * 3 + col

playDrumNote = (note) ->
  drumkit.noteOn note
  $($('#drumkit .span3').get(convertIndex(note - drumkit.rootNote))).css('border-color', 'rgba(0, 255, 0, 0.4)').animate
    'border-color': 'rgba(0, 0, 0, 0.4)'

Template.drumpads.rendered = ->
  window.drumkit = new Drumkit()
  drumkit.connect masterGainNode
  keyboard = new VirtualKeyboard
    noteOn: playDrumNote
    noteOff: (note) ->
      drumkit.noteOff note

  $drumkit = $('#drumkit')
  resize = ->
    verticalSpace = $(window).height() - $drumkit.offset().top - 200
    $drumkit.find('.span3').height(verticalSpace / 4)
  $(window).resize ->
    resize()
  resize()
  $drumkit.find('.span3').droppable
    drop: (e, ui) ->
      index = $(this).index '#drumkit .span3'
      sampleIndex = convertIndex index
      buffer = ui.draggable.data 'buffer'
      url = ui.draggable.data 'url'
      ui.draggable.parent().remove()
      drawWaveform buffer, $(this).find('canvas')[0], 'rgba(0, 0, 0, 0.4)'
      drumkit.samples[sampleIndex] = buffer
      drumkit.sampleUrls[sampleIndex] = url

  $drumkit.find('.span3').click ->
    playDrumNote(convertIndex($(this).index('#drumkit .span3')) + drumkit.rootNote)

Template.drumkit.events
  'keydown input': (e) ->
    typingTimer = Meteor.setTimeout fetchResults, checkInterval
  'keyup input': (e) ->
    Meteor.clearTimeout typingTimer

Template.drumkit.results = ->
  Session.get 'search_results'


