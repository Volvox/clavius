class ClipPreview
  constructor: (clip) ->
    @clip = clip
    @soundsloaded = 0
    console.log(@clip)
    @soundbank = []
    for sound in @clip.sounds
      @soundbank.push new Audio(sound['preview-hq-ogg'])


  playNote: (i) =>
    note = @clip.notes[i]
    @soundbank[note.sound].currentTime = 0
    @soundbank[note.sound].play()
    if i < @clip.notes.length - 1
      next = @clip.notes[i+1].start - note.start
      if next == 0
        @playNote(i+1)
      else
        playNext = =>
          @playNote(i+1)
        @ticker = Meteor.setTimeout(playNext, next)


  play: ->
    @loadListeners()
    if @ready.length is @soundbank.length
      console.log("ready")
      @playNote(0)
    else
      console.log("not ready yet...")
      Meteor.setInterval(@play,5000)



  stop: ->
    Meteor.clearTimeout @ticker

  loadListeners: =>
    @ready = []
    for sound in @soundbank
      $(@soundbank[sound]).on 'loadeddata', =>
        @ready[sound].push(true)


    # $(@ready).bind 'state', =>
    #   if @ready.length is @soundbank.length
    #     true
    #     $(@ready).trigger('state')






