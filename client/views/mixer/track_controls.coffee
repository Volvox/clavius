Template.track_controls.events
  'dblclick': (e, template) ->
    startTime = audioContext.currentTime
    for clip in template.data.clips
      for note in clip.data.notes
        mainInstrument.noteOn note.sound, startTime + clip.start + note.start
        mainInstrument.noteOff note.sound, startTime + clip.start + note.stop

