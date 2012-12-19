Template.clips.rendered = ->
  $(@find('.clips')).droppable
    drop: (e, ui) =>
      song_id = $('#tracks').attr('data-song-id')
      song = Songs.findOne _id: song_id
      clip = Clips.findOne _id: ui.draggable.attr('data-id')
      if clip?
        track = $('.clips').index(e.target)
        startTime = ui.offset.left - e.target.offsetLeft
        endTime = startTime + (clip.duration ? 250) # FIXME
      
        update = {}
        update["tracks.#{track}.clips"] =
          start: startTime
          stop: endTime
          data: clip
        Songs.update {_id: song_id}, $push: update
