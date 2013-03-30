class Sequencer
  constructor: (canvas) ->
    @current = 0
    @cursor = 0
    @hold = false
    @transpose_sequence = false
    @octave = 1
    @letters = "awsedrfgyhujkolp;['".split ''
    @noteMin = 35 # B-3
    @noteMax = 71 # B0
    Session.set('bpm', 120)
    Session.set('note', 0.25)
    Session.set('columns', 32)

    @initializeCanvas canvas
    @bindKeys()
    @draw()
    @play()

  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $(canvas).parent().height()
    @canvas.width = $(canvas).parent().width()
    @resizeGrid()

  resizeGrid: ->
    @current = 0
    @numColumns = Session.get('columns')
    @tile_height = Math.floor(@canvas.height / @numRows())
    @tile_width = Math.floor(@canvas.width / (@numColumns + 1))
    @state = []
    for col in [0...@numColumns]
      @state[col] = []
      for row in [0...@numRows()]
        @state[col][row] = false

  numRows: ->
    @noteMax - @noteMin

  bindKeys: () ->
    Mousetrap.reset()
    Mousetrap.bind "space", =>
      @toggle()

    #move green cursor to insert notes
    Mousetrap.bind "right", =>
      @cursor += 1
      if @cursor == @numColumns
        @cursor = 0

    Mousetrap.bind "left", =>
      @cursor -= 1
      if @cursor == 0
        @cursor = @numColumns-1

    #shift octave up and down
    Mousetrap.bind "shift+up", =>
      @noteMin += 12
      @noteMax += 12
      Session.set "display-octave", @noteMin

    Mousetrap.bind "shift+down", =>
      @noteMin -= 12
      @noteMax -= 12
      Session.set "display-octave", @noteMin

    for letter, i in @letters
      do (letter, i) =>
        row = @numRows() - 1 - i
        Mousetrap.bind "shift+#{letter}", =>
          @state[@cursor][row] = not @state[@cursor][row]

    @keyboard = new VirtualKeyboard
      noteOn: (note) =>
        @instrument.noteOn note, 0
      noteOff: (note) =>
        @instrument.noteOff note, 0

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: =>
    requestAnimationFrame @draw

    @clear()
    @drawGrid()
    @drawNotes()
    @highlightColumn @cursor, 'rgba(55, 255, 172, 0.8)'

    @highlightColumn (@current + @numColumns - 1) % @numColumns

  drawGrid: ->
    ctx = @canvas.getContext '2d'
    ctx.strokeStyle = 'rgba(0, 0, 0, 0.4)'

    for row in [0...@numRows()]
      offset =  (1 + row) * @tile_height
      ctx.beginPath()
      ctx.moveTo 0, offset
      ctx.lineTo @canvas.width, offset
      ctx.stroke()

    for col in [0...@numColumns]
      offset =  (1 + col) * @tile_width
      ctx.beginPath()
      ctx.moveTo offset, 0
      ctx.lineTo offset, @canvas.height
      ctx.lineWidth = if col % 4 is 0 then 5 else 1
      ctx.stroke()

  drawNotes: ->
    for col of @state
      for row of @state[col]
        if @state[col][row]
          @drawDot row, col

  drawDot: (row, col) ->
    ctx = @canvas.getContext '2d'
    if @state[col][row]
      ctx.fillStyle = 'rgba(0, 0, 255, 0.4)'
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'
    x = col * @tile_width + @tile_width
    y = row * @tile_height + @tile_height
    radius = 3
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
    ctx.fill()

  highlightColumn: (col, color) ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = color or 'rgba(0, 0, 255, 0.4)'
    x = col * @tile_width + @tile_width
    ctx.fillRect x, 0, 5, @canvas.height

  setInstrument: (instrument) ->
    if @instrument?
      @instrument.disconnect()
    @instrument = instrument
    @instrument.connect masterGainNode

  schedule: =>
    currentTime = audioContext.currentTime
    currentTime -= @startTime # normalize to 0

    while @noteTime < currentTime + 0.040
      contextPlayTime = @noteTime + @startTime # convert note time to context time
      for active, row in @state[@current]
        if active
          @playNote @getNote(row), contextPlayTime

      @advanceNote()

    @ticker = Meteor.setTimeout @schedule, 0

  advanceNote: ->
    @current += 1
    if @current == @numColumns
      @current = 0

    @noteTime += @tickLength()

  playNote: (note, time) ->
    time ?= audioContext.currentTime
    @instrument.noteOn note, time
    @instrument.noteOff note, time + @tickLength()

  getNote: (row) ->
    @noteMax - row

  getRow: (note) ->
    @noteMax - note

  play: ->
    @noteTime = 0.0
    @startTime = audioContext.currentTime + 0.005
    @schedule()

  stop: ->
    Meteor.clearTimeout @ticker

  tickLength: ->
    Session.get('note') * (60.0 / Session.get('bpm'))

  toggle: ->
    $(".hold").toggleClass("held")
    @hold = not @hold
    if @hold then @stop() else @play()

  click: (e, force) ->
    coords = @getCoords e
    row = Math.round(coords.y / @tile_height) - 1
    col = Math.round(coords.x / @tile_width) - 1
    if 0 <= row < @numRows() and 0 <= col < @numColumns
      if force?
        @state[col][row] = force
      else
        @state[col][row] = not @state[col][row]

  getCoords: (e) ->
    x: e.pageX - @canvas.offsetLeft
    y: e.pageY - @canvas.offsetTop

  export: () ->
    notes = []
    for col of @state
      for active, row in @state[col]
        if active
          notes.push
            sound: @getNote row
            start: col * @tickLength()
            stop: col * @tickLength() + @tickLength()

    notes: notes
    numColumns: Session.get('columns')
    bpm: Session.get('bpm')

  buildLib: (exportObject) ->
    Meteor.call("createClip", exportObject)

  reset: ->
    for col in [0...@numColumns]
      @state[col] = []
      for row in [0...@numRows()]
        @state[col][row] = false

  import: (clip) ->
    Session.set 'bpm', clip.bpm
    @numColumns = clip.numColumns
    pitches = (note.sound for note in clip.notes)
    @noteMin = Math.min(pitches...)
    @noteMax = Math.max(pitches...)
    @reset()
    @resizeGrid()

    for note in clip.notes
      tickLength = note.stop - note.start
      col = note.start / tickLength
      row = @getRow note.sound
      if @state[col]? and @state[col][row]?
        @state[col][row] = true

Template.sequencer.bpm = ->
  Session.get('bpm')

Template.sequencer.hidden = ->
  Session.get('hidden')

Template.sequencer.octave = ->
  Session.get('display-octave')

Template.sequencer.events
  'change .bpm': (e) ->
    val =  Number($(e.srcElement).val())
    if val > 0
      Session.set 'bpm', val
  'change .bars': (e) ->
    val =  Number($(e.srcElement).val())
    Session.set 'columns', val
    sequencer.resizeGrid()
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
    sequencer.setInstrument instrument
    e.srcElement.blur()
  'click #note-picker path': (e) ->
    val = Number($(e.srcElement).data("note"))
    $("#note-picker path").css "opacity", "0.5"
    $(e.srcElement).css "opacity", "1"
    Session.set "note", val
  'click .hold': (e) ->
    sequencer.toggle()
  'click #save': (e) ->
    e.preventDefault()
    sequencer.buildLib(sequencer.export())
  'click #clear': (e) ->
    sequencer.reset()
  'click #toggle-trans': (e) ->
    e.preventDefault()
    text = $("#toggle-trans").text()
    $("#toggle-trans").toggleClass("btn btn-small btn-primary").text(if text is "OFF" then "ON" else "OFF")
    sequencer.transpose_sequence = not sequencer.transpose_sequence
    sequencer.bindKeys()
