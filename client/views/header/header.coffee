Template.header.events
  'click #recordButton': (e) ->
    unless Session.get('recording')
      Session.set('recording', false)

    if Session.get('recording')
      Session.set('recording', false)
      App.recorder.stop()
      App.recorder.exportWAV (blob) ->
        Recorder.forceDownload blob, "My Song.wav"
        App.recorder.clear()
    else
      Session.set('recording', true)
      App.recorder.record()

Template.header.recording = ->
  Session.get 'recording'
