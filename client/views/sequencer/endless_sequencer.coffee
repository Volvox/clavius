class EndlessSequencer
  constructor: ->
    #counter variable for showing the current step as it changes
    # Session.set('count', 0)

    #note length
    Session.set('note', 0.25)
    #total number of steps stored
    Session.set('steps', 0)
    #insert mode on/off
    Session.set('insert', false)

    #current step
    @noteMin = 35 # B-3
    @noteMax = 71 # B0
    @maxNotes = 256
    @letters = "awsedrfgyhujkolp;['".split ''
    @state = []
    @transpose = false
    @bindKeys()

  bindKeys: ->
    Mousetrap.reset()

    if @transpose is false
      @keyboard = new VirtualKeyboard
        noteOn: (note) =>
          @instrument.noteOn note, 0
        noteOff: (note) =>
          @instrument.noteOff note, 0

    else
      for letter, i in @letters
        do (letter, i) =>
          semitone = @numNotes() - 1 - i
          Mousetrap.bind letter, (=>
            for data, i in @state
              masterGainNode.gain.value = 1
              @playNote(data.note, data.start, data.stop, semitone)
              @keyDown = true
              ), 'keydown'
          Mousetrap.bind letter, (=>
            for data in @state
              masterGainNode.gain.value = 0
              @keyDown = false
              ), 'keyup'

    Mousetrap.bind "shift", =>
      Session.set('insert', true)
      for letter, i in @letters
        #reset state
        @count = 0
        do (letter, i) =>
          note = @numNotes() - 1 - i
          Mousetrap.bind letter, =>
              @state.push(
                  note: @getNote(note)
                  start: audioContext.currentTime
                  stop: audioContext.currentTime + @noteLength()
                  )
              if Session.equals('insert', true)
                @count += 1
                $('#step').text(@count)
              Mousetrap.bind "right", =>
                if Session.equals('insert', true)
                  @count += 1
                  $('#step').text(@count)

            #done inserting notes
            Mousetrap.bind "shift", =>
              Session.set('insert', false)

              #playback recorded sequence on keys
              @transpose = true
              @bindKeys()


  getNote: (note) ->
    @noteMax - note

  numNotes: ->
    @noteMax - @noteMin

  playNote: (note, start, stop, pitch) ->
    time = stop - start
    time += audioContext.currentTime
    console.log time
    # console.log time+@noteLength()
    @instrument.noteOn note, time
    @instrument.noteOff note, time + @noteLength()
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
  console.log endless
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