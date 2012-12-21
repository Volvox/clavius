Template.freesound_result.rendered = ->
  loader = new BufferLoader audioContext, [@data['preview-hq-ogg']], (bufferList) =>
    buffer = bufferList[0]
    canvas = @find('canvas')
    drawWaveform buffer, canvas

    $(canvas).click ->
      source = audioContext.createBufferSource()
      source.buffer = buffer
      source.connect masterGainNode
      source.start 0

    $(canvas).draggable
      helper: 'original'
      revert: true
      distance: 10

    $(canvas).data 'buffer', buffer

  loader.load()
