class EndlessSequencer
  constructor: ->
    #counter variable for showing the current step as it changes
    # Session.set('count', 0)

    #note length
    Session.set('note', 0.25)
    #total number of steps stored
    Session.set('steps', 0)
    #insert mode on/off
    @insert = false

    #current step
    @noteMin = 35 # B-3
    @noteMax = 71 # B0
    @maxNotes = 256
    @letters = "awsedrfgyhujkolp;['".split ''
    @state = []
    @bindKeys()

  bindKeys: ->
    Mousetrap.reset()

    @keyboard = new VirtualKeyboard
      noteOn: (note) =>
        @instrument.noteOn note, 0
      noteOff: (note) =>
        @instrument.noteOff note, 0

    Mousetrap.bind "shift", =>
      @insert = not @insert
      @bindKeys()
      @count = 1
      for letter, i in @letters
        do (letter, i) =>
          note = @numNotes() - 1 - i
          if @insert
            Mousetrap.bind letter, =>
              start = @count * 0.125
              $('#step').text(@count)
              @state.push(
                note: @getNote(note)
                root: letter
                start: start
                stop: start + 0.125
              )
              @count += 1
              Mousetrap.bind "right", =>
                @count+=1
          else
            #playback mode: insert is false and notes have been stored to the state
            Mousetrap.bind letter, (=>
              @transposePitch = note
              @playback(letter)
            ), 'keydown'

            # stop playback
            Mousetrap.bind letter, (=>
              Meteor.clearTimeout @ticker
            ), 'keyup'

  copyState: ->
    @queue = []
    for data in @state
      @queue.push(data)

  playback: (letter) ->
    @copyState()
    console.log @queue
    @startTime = audioContext.currentTime
    @noteTime = 0.0
    @schedule()

  schedule: ->
    if @queue[0]?
      scheduledToStart = (@queue[0].start + @startTime) - audioContext.currentTime
      while scheduledToStart < 0.200
        next = @queue.shift()
        @instrument.noteOn next.note, @startTime + next.start
        @instrument.noteOff next.note, @startTime + next.stop
      if @queue[0]?
        @ticker = Meteor.setTimeout @schedule, 0



  getNote: (note) ->
    @noteMax - note

  numNotes: ->
    @noteMax - @noteMin

  playNote: (data, count) ->
    if count is 0
      console.log count
      @instrument.noteOn data.note, 0
    else
      @instrument.noteOn data.note, audioContext.currentTime + @noteLength()
    @instrument.noteOff data.note, audioContext.currentTime + (@noteLength() * count)
    # $('#step').text(@count)

  noteLength: ->
    0.25 * (60.0 / 120)

  setInstrument: (instrument) ->
    if @instrument?
      @instrument.disconnect()
    @instrument = instrument
    @instrument.connect masterGainNode

Template.endless.rendered = ->
  window.endless = new EndlessSequencer()
  endless.setInstrument(new Polyphonic(FMSynthesizer))


Template.endless.events
'change .instrument': (e) ->
  val = $(e.srcElement).val()
  switch val
    when 'additive'
      instrument = new Polyphonic(AdditiveSynthesizer)
    when 'subtractive'
      instrument = new Polyphonic(SubtractiveSynthesizer)
    when 'fm'
      instrument = new Polyphonic(FMSynthesizer)
    when 'drumkit'
      instrument = new FreesoundSampler(7417)