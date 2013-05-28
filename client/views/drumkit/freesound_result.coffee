Template.freesound_result.rendered = ->
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
