class @Clip
  start: (time) ->
    console.log 'override in subclass'

  stop: (time) ->
    console.log 'override in subclass'

  duration: ->
    console.log 'override in subclass'
    0.0

  beats: ->
    bps = Session.get('bpm') / 60
    bps * @duration()

  playing: ->
    false

class @AudioClip
  constructor: (params) ->
    @buffer = params.buffer
    @bpm = params.bpm ? Session.get 'bpm'
    @source = null
    @nextTime = null

  start: (time, loopPlayback=false) ->
    time ?= App.audioContext.currentTime
    @nextTime = time
    @source = App.audioContext.createBufferSource()
    @source.buffer = @buffer
    @source.loop = loopPlayback
    @source.connect App.masterGainNode
    @source.start time

  stop: (time) ->
    time ?= App.audioContext.currentTime
    @nextTime = time
    @source.stop time
    @source = null

  duration: ->
    return @buffer.duration

  playing: ->
    @source?
