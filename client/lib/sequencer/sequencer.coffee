class @Sequencer
  constructor: (canvas) ->
    @current = 0
    @cursor = 0
    @hold = false
    @transpose_sequence = false
    @octave = 1
    @gridSize = 20
    @letters = "awsedrfgyhujkolp;['".split ''
    @noteMin = 60 # B-3
    @noteMax = 81 # B0
    Session.set('bpm', 120)
    Session.set('note', 0.25)
    Session.set('columns', 32)
    @initializeCanvas canvas
    @bindKeys()
    @draw()
    @drawResizable()
    @play()


  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $(canvas).parent().height()
    @canvas.width = $(canvas).parent().width()
    @resizeGrid()

  resizeGrid: ->
    @current = Math.floor($("#left").width() / @gridSize)
    @cursor = @current
    @numRows = Math.floor(@canvas.height / @gridSize) - 1
    @numColumns = Math.floor(@canvas.width / @gridSize)
    @state = []
    for col in [0...@numColumns]
      @state[col] = []
      for row in [0...@numRows]
        @state[col][row] = false

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
        row = @numRows - 1 - i
        Mousetrap.bind "shift+#{letter}", =>
          @state[@cursor][row] = not @state[@cursor][row]

  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  draw: =>
    requestAnimationFrame @draw

    @clear()
    @drawGrid()
    @drawBorder()
    @drawNotes()
    @highlightColumn @cursor, 'rgba(55, 255, 172, 0.8)'
    @highlightColumn (@current + @numColumns - 1) % @numColumns

  drawResizable: ->
    $( "#right" ).resizable
      containment: "parent"
      maxWidth: (@canvas.width - $("#left").width()) - (@gridSize * 4)
      grid: [ @gridSize, 0 ]
      handles: "w"
      resize: =>
        @drawResizable()
        Session.set('mousedown', false)
      stop: =>
        @resizeGrid()

    $( "#left" ).resizable
      containment: "parent"
      maxWidth: $("#right").position().left - (@gridSize * 4)
      grid: [ @gridSize, 0 ]
      handles: "w, e"
      resize: =>
        @drawResizable()
        Session.set('mousedown', false)
      stop: =>
        @resizeGrid()

  drawBorder: ->
    ctx = @canvas.getContext '2d'
    ctx.strokeStyle = 'rgb(89,66,266)';
    ctx.lineWidth = 4

    for y in [0, @canvas.height]
      ctx.beginPath()
      ctx.moveTo 0, y
      ctx.lineTo @canvas.width, y
      ctx.stroke()

  drawGrid: ->
    ctx = @canvas.getContext '2d'
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)'

    for row in [0...@numRows]
      offset =  (1 + row) * @gridSize
      ctx.beginPath()
      ctx.moveTo 0, offset
      ctx.lineTo @canvas.width, offset
      ctx.lineWidth = 1
      ctx.stroke()

    for col in [0...@numColumns]
      offset =  (1 + col) * @gridSize
      ctx.beginPath()
      ctx.moveTo offset, 0
      ctx.lineTo offset, @canvas.height
      ctx.lineWidth = if col % 4 is 0 then 2 else 1
      ctx.stroke()

  drawNotes: ->
    for col of @state
      for row of @state[col]
        if @state[col][row]
          @drawDot row, col

  drawDot: (row, col) ->
    ctx = @canvas.getContext '2d'
    if @state[col][row]
      ctx.fillStyle = '#fa435f'
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'
    x = col * @gridSize + @gridSize
    y = row * @gridSize + @gridSize
    radius = 3
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
    ctx.fill()

  highlightColumn: (col, color) ->
    ctx = @canvas.getContext '2d'
    ctx.fillStyle = color or 'rgba(0, 0, 255, 0.8)'
    ctx.lineWidth = 4
    x = col * @gridSize + @gridSize
    ctx.fillRect x, 0, 2, @canvas.height

  schedule: =>
    currentTime = App.audioContext.currentTime
    currentTime -= @startTime # normalize to 0

    while @noteTime < currentTime + 0.040
      contextPlayTime = @noteTime + @startTime # convert note time to context time
      for active, row in @state[@current]
        if active
          @playNote @getNote(row), contextPlayTime

      @advanceNote()

    @ticker = Meteor.setTimeout @schedule, 0

  advanceNote: ->
    position = $("#right").position()
    @current += 1
    if @current == Math.floor(position.left / @gridSize) + 1
      @current = Math.floor($("#left").width()/@gridSize)

    @noteTime += @tickLength()

  playNote: (note, time) ->
    time ?= App.audioContext.currentTime
    App.instrument.noteOn note, time
    App.instrument.noteOff note, time + (60.0 / Session.get('bpm'))

  getNote: (row) ->
    @noteMax - row

  getRow: (note) ->
    @noteMax - note

  play: ->
    @noteTime = 0.0
    @startTime = App.audioContext.currentTime + 0.005
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
    row = Math.round(coords.y / @gridSize) - 1
    col = Math.round(coords.x / @gridSize) - 1
    if 0 <= row < @numRows and 0 <= col < @numColumns
      if force?
        @state[col][row] = force
      else
        @state[col][row] = not @state[col][row]

  getCoords: (e) ->
    x: e.pageX - $(@canvas).offset().left
    y: e.pageY - $(@canvas).offset().top

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
      for row in [0...@numRows]
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
        setInstrument new AdditiveSynthesizer
      when 'subtractive'
        setInstrument new SubtractiveSynthesizer
      when 'fm'
        setInstrument new FMSynthesizer
      when 'drumkit'
        setInstrument new FreesoundSampler(7417)
    e.srcElement.blur()
  'click #note-picker path': (e) ->
    note = $(e.srcElement).data("note")
    $.each $("#note_display span"), ->
      if $(@).data("note") is note
        $(@).css "display", "block"
      else
        $(@).css "display", "none"
    $("#note-picker path").css "opacity", "0.5"
    $(e.srcElement).css "opacity", "1"
    Session.set "note", Number(note)
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
  'hover #note-picker path': ->
    $(@).css "opacity", "0.75"


