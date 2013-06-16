class EndlessSequencer
  constructor: ->
    #insert mode on/off
    @insert = false
    @noteMin = 35 # B-3
    @noteMax = 71 # B0
    @maxNotes = 256
    @state = []
    @paper = paper
    Session.set('note', 0.25)
    @bindKeys()

  bindKeys: ->
    Mousetrap.reset()

    @keyboard = new VirtualKeyboard
      noteOn: (note) =>
        if @insert
          @insertNote(note)
          @instrument.noteOn note, 0
        else
          @initiatePlayback(note)
      noteOff: (note) =>
        if @insert
         @advanceNote(note)
         @instrument.noteOff note, 0
        else
          @stopPlayback(note)

    Mousetrap.bind "shift", (=>
      @toggleInsertMode()
    ), 'keydown'
    Mousetrap.bind 'shift', (=>
      @stopPlayback()
    ), 'keyup'
    Mousetrap.bind "right", =>
      @advanceNote()

  toggleInsertMode: ->
    @insert = not @insert
    @count = 1

  advanceNote: ->
    @count+=1
    $('#step').text(@count)

  initiatePlayback: (note) ->
    @step = 1
    @playback(note)

  insertNote: (note) ->
    start = @count * @noteLength()
    $('#step').text(@count)
    @state.push(
      note: note
      start: start
      stop: start + Session.get('note')
    )

  copyState: ->
    @queue = []
    for data in @state
      @queue.push(data)

  playback: (note) ->
    @noteTime = 0.0
    @copyState()
    @startTime = audioContext.currentTime
    offset = note - @state[0].note
    @schedule(offset)

  stopPlayback: =>
    Meteor.clearTimeout @ticker

  schedule: (offset) =>
    if @queue.length is 0
      @step = 1
      $('#step').text(@step)
      @copyState()
      @startTime += @queue[@queue.length-1].stop

    while @queue[0]? and (@startTime + @queue[0].start) - audioContext.currentTime < 0.2
      next = @queue.shift()
      @step+=1
      $('#step').text(@step)
      @noteTime += @noteLength()
      @instrument.noteOn next.note, (@startTime + (next.start+@noteTime))
      @instrument.noteOff next.note, @startTime #+ next.stop)

    @ticker = Meteor.setTimeout @schedule, 0

  numNotes: ->
    @noteMax - @noteMin

  noteLength: ->
    Session.get('note') * (60.0 / 120)


  setInstrument: (instrument) ->
    if @instrument?
      @instrument.disconnect()
    @instrument = instrument
    @instrument.connect masterGainNode

Template.endless.rendered = ->
  window.endless = new EndlessSequencer()
  drumkit = new Drumkit()
  freesoundIds = [26885, 26887, 26900, 26902, 26896, 26889, 26879, 26880, 26881, 26883, 26884, 26878]
  for id, i in freesoundIds
    do (id, i) ->
      getFreesoundSample id, (sound) ->
        drumkit.loadSample sound['preview-hq-ogg'], i
  endless.setInstrument(drumkit)


Template.endless.events
'change .instrument': (e) ->
  val = $(e.srcElement).val()
  switch val
    when 'additive'
      instrument = new AdditiveSynthesizer()
    when 'subtractive'
      instrument = new SubtractiveSynthesizer()
    when 'fm'
      instrument = new Polyphonic(FMSynthesizer)
    when 'drumkit'
      instrument = new FreesoundSampler(7417)