fetchResults = ->
  query = $('.freesound-search input').val()
  searchFreesound q: query, f: 'duration:[3.8 TO 16.4]' , (results) ->
    Session.set 'sampler_results', results

drawWaveform = (buffer, canvas, color) ->
  ctx = canvas.getContext '2d'
  width = canvas.width
  height = canvas.height
  ctx.fillStyle = color ? 'rgb(15, 151, 154)'
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

msToTime = (position) ->
  displayRemainingTime = false
  showMs = true
  ms = parseInt(position % 1000)
  if ms < 10
    ms = "00" + ms
  else if ms < 100
    ms = "0" + ms
  else
    ms = "" + ms
  s = parseInt(position / 1000)
  seconds = parseInt(s % 60)
  if seconds < 10
    seconds = "0" + seconds
  else
    seconds = "" + seconds
  minutes = "0"
  if showMs
    ((if displayRemainingTime then "-" else " ")) + minutes + ":" + seconds + ":" + ms
  else
    ((if displayRemainingTime then "-" else " ")) + minutes + ":" + seconds

Template.sampler_result.rendered = ->
  loader = new BufferLoader App.audioContext, [@data['preview-hq-ogg']], (bufferList) =>
    buffer = bufferList[0]
    canvas = @find('canvas')
    drawWaveform buffer, canvas

    $(canvas).click ->
      source = App.audioContext.createBufferSource()
      source.buffer = buffer
      source.connect App.masterGainNode
      source.start 0

    $(canvas).draggable
      helper: 'original'
      revert: true
      distance: 10

    $(canvas).data 'buffer', buffer
    $(canvas).data 'url', @data['preview-hq-ogg']

  loader.load()

Template.sampler_result.duration = ->
  msToTime (@duration * 1000)

Template.sampler.results = ->
  Session.get 'sampler_results'

Template.sampler.events
  'keydown input': _.debounce(fetchResults, 350)
