class VirtualKeyboard extends Input
  constructor: (params) ->
    params = params or {}
    @lowestNote = params.lowestNote or 60
    @noteOn = params.noteOn or (note) -> console.log "noteOn: #{note}"
    @noteOff = params.noteOff or (note) -> console.log "noteOff: #{note}"
    @octaveUp = params.octaveUp or (newOctave) =>
      _.each [@lowestNote - 12...@lowestNote], (note) =>
        @noteOff note
    @octaveDown = params.octaveDown or (newOctave) =>
      _.each [@lowestNote + 12...@lowestNote + 24], (note) =>
        @noteOff note
    @letters = (params.letters or "awsedftgyhujkolp;'").split ''
    @keysPressed = {}

    for letter, i in @letters
      do (letter, i) =>
        Mousetrap.bind letter, (=>
          note = @lowestNote + i
          unless note of @keysPressed
            @keysPressed[note] = true
            @noteOn note
        ), 'keydown'
        Mousetrap.bind letter, (=>
          note = @lowestNote + i
          if note of @keysPressed
            delete @keysPressed[note]
            @noteOff note
        ), 'keyup'

    Mousetrap.bind 'z', =>
      # shift one octave down
      @lowestNote -= 12
      @octaveDown (noteOctave @lowestNote)
  
    Mousetrap.bind 'x', =>
      # shift one octave up
      @lowestNote += 12
      @octaveUp (noteOctave @lowestNote)

