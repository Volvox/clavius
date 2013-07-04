class @ClipEditor #extends Sequencer
  constructor: (params) ->
    @initializeCanvas(params.canvas)
    @initializeTooltip()
    @current = 0
    @cursor = 0
    @lightness = 60
    @hold = false
    @letters = "awsedrfgyhujkolp;['".split ''
    @steps = @numRows
    @noteMin = 60 # B-3
    @noteMax = 81 # B0
    Session.set("lightness", @lightness)
    Session.set('bpm', 120)
    Session.set('note', 0.25)
    Session.set("steps", @steps)
    @bindKeys()
    @draw()
    @play()

  bindKeys: ->
    forward = "right"
    backward = "left"

    Mousetrap.reset()
    Mousetrap.bind "space", =>
      @toggle()

    Mousetrap.bind forward, =>
      @cursor += 1
      if @cursor == @steps
        @cursor = 0

    Mousetrap.bind backward, =>
      @cursor -= 1
      if @cursor == 0
        @cursor = @steps-1

    #shift octave up and down
    Mousetrap.bind "shift+up", =>
      @noteMin += 12
      @noteMax += 12
      @lightness += 5
      Session.set "display-octave", @noteMin
      Session.set "lightness", @lightness


    Mousetrap.bind "shift+down", =>
      @noteMin -= 12
      @noteMax -= 12
      @lightness -= 5
      Session.set "lightness", @lightness
      Session.set "display-octave", @noteMin

    for letter, i in @letters
      do (letter, i) =>
        row = @numRows - 1 - i
        Mousetrap.bind "shift+#{letter}", =>
          @state[@cursor][row] = not @state[@cursor][row]


  clear: ->
    ctx = @canvas.getContext '2d'
    ctx.clearRect 0, 0, @canvas.width, @canvas.height

  initializeCanvas: (canvas) =>
    @resize()
    @canvas = canvas
    @cellWidth = 18
    @cellHeight = @cellWidth/2
    @canvas.height = $(canvas).parent().height() -  $("#options").height()
    @numColumns = 12
    @canvas.width =  @offsetCol(@numColumns)
    @numRows = Math.floor( @canvas.height / @cellHeight ) - 1
    @state = []
    for row in [0...@numRows]
      @state[row] = []
      for col in [0...@numColumns]
        @state[row][col] = false

  initializeTooltip: ->
    $("[rel='tooltip']").tooltip
      placement: "bottom"

  draw: =>
    requestAnimationFrame @draw
    @clear()
    @drawGrid()
    @drawNotes()
    @highlightStep @cursor, @hsl 0
    row = (@current + @numRows - 1) % @numRows
    @highlightStep row

  drawGrid: =>
    ctx = @canvas.getContext "2d"
    color = 'hsl(258, 42%, 15%)'
    for row in [0...@numRows]
      for col in [0...@numColumns]
        ctx.beginPath()
        ctx.rect(@offsetCol(col), @offsetRow(row), @cellWidth, @cellHeight)
        ctx.fillStyle = color
        ctx.fill()

  offsetCol: (col) ->
    (col * @cellWidth) * 1.1

  offsetRow: (row) ->
    row * (@cellWidth/1.6)

  resize: ->
    height = $("#effects").position().top
    $("#editor-canvas").css "height", height - 2
    $("#editor-canvas canvas").css "height", height - 65

  toggleEffects: ->
    _.each $(".effect"), (effect, i) ->
      if $(effect).hasClass "active"
        App.effectsPipeline.reset()
        $(effect).removeClass "active"
        $(effect).addClass "inactive"
      else if $(effect).hasClass "inactive"
        className = effect.classList[0]
        App.effectsPipeline.addEffect App.effects[className], className
        $(effect).removeClass "inactive"
        $(effect).addClass "active"

  highlightStep: (row, color) ->
    ctx = @canvas.getContext "2d"
    ctx.fillStyle = color or 'rgba(0, 0, 255, 0.8)'
    ctx.lineWidth = 4
    y = row * @cellHeight + @cellHeight
    ctx.fillRect 0, y, @canvas.width, 2

  drawNotes: ->
    for col of @state
      for row of @state[col]
        if @state[col][row]
          @drawNote row, col

  drawNote: (col, row) ->
    ctx = @canvas.getContext '2d'
    if @state[row][col]
      if col % 2 is 0
        ctx.fillStyle = @hsl col
      else
        ctx.fillStyle = @hsl col, "30", "40"
    else
      ctx.fillStyle = 'rgb(255, 255, 255)'

    x = @offsetCol(col)
    y = @offsetRow(row)
    ctx.beginPath()
    ctx.fillRect(x, y, @cellWidth, @cellHeight)
    ctx.fill()

  schedule: =>
    currentTime = App.audioContext.currentTime
    currentTime -= @startTime # normalize to 0

    while @noteTime < currentTime + 0.040
      contextPlayTime = @noteTime + @startTime # convert note time to context time
      for active, col in @state[@current]
        if active
          @playNote @getNote(col), contextPlayTime

      @advanceNote()
    @ticker = Meteor.setTimeout @schedule, 0

  advanceNote: ->
    @current += 1
    if @current is @steps
      @current = 0
    # if @current == Math.floor(position.left / @gridSize) + 1
    #   @current = Math.floor($("#left").width()/@gridSize)

    @noteTime += @tickLength()

  playNote: (note, time) ->
    time ?= App.audioContext.currentTime
    App.instrument.noteOn note, time
    App.instrument.noteOff note, time + (60.0 / Session.get('bpm'))

  getNote: (col) ->
    @noteMax - col

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

  click: (e, force) ->
    coords = @getCoords e
    row = Math.round(coords.y / @cellHeight) - 1
    col = Math.round(coords.x / @cellWidth) - 1
    if 0 <= row < @numRows and 0 <= col < @numColumns
      if force?
        @state[row][col] = force
      else
        @state[row][col] = not @state[row][col]

  getCoords: (e) ->
    x: e.pageX - $(@canvas).offset().left
    y: e.pageY - $(@canvas).offset().top

  reset: ->
    for row in [0...@numRows]
      @state[row] = []
      for col in [0...@numColumns]
        @state[row][col] = false

  hsl: (index, s, l, a) ->
    colors = [
      "351, 96%, 55%",   #red
      "52, 97%, 76%",    #yellow
      "195, 78%, 42%",   #blue
      "38, 98%, 55%",    #orange
      "162, 98%, 34%",   #green
      "328, 95%, 70%",   #pink
      "248, 77%, 58%",   #purple
      "108, 100%, 100%"  #white
      ]
    index = Math.floor(index / 2)
    hsl =  colors[index].split ","
    hue = hsl[0]
    s ?= hsl[1].replace "%", ""
    l ?= Session.get("lightness")
    a ?= "100%"
    "hsl(#{hue}, #{s}%, #{l}%)"


Template.editor.rendered = ->
  App.editor ?= new ClipEditor
    canvas: $("#clip-editor canvas")[0]

  $(window).resize ->
    App.editor.resize()

Template.editor.events
  'mousedown': (e) ->
    Session.set('mousedown', true)
    App.editor.click e
  'mouseup': (e) ->
    Session.set('mousedown', false)
  'mousemove': (e) ->
    if Session.get('mousedown')
      App.editor.click e, true

  "click #clip-editor .glyph-btn": (e) ->
    action = $(e.srcElement).attr "data-original-title"
    switch action
      when "toggle FX" then App.editor.toggleEffects()
      when "library" then App.editor.showLibrary()
