class @Sequencer
  constructor: (params) ->
    @current = 0
    @cursor = 0
    @state = []
    @hold = false
    @octave = 1
    @cellSize = 20
    @steps = params.steps or params.canvas.columns
    @letters = "awsedrfgyhujkolp;['".split ''
    @noteMin = 60 # B-3
    @noteMax = 81 # B0
    Session.set('bpm', 120)
    Session.set('note', 0.25)
    Session.set("steps", @steps)
    @methods(params)

    methods: (params) ->
      @initializeCanvas params.canvas
      @bindKeys params.keys
      @draw()
      @play()

    bindKeys: (options) ->
      # default to horizontally oriented bindings
      forward = options.forward ? "right"
      backward = options.backward ? "left"

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

    initializeCanvas: (canvas) ->
      @canvas = canvas.canvas
      @canvas.height = canvas.height or $(canvas).parent().height()
      @canvas.width = canvas.width or $(canvas).parent().width()
      @numColumns = canvas.columns or Math.floor(@canvas.width / @gridSize)
      @numRows = canvas.rows or Math.floor(@canvas.height / @gridSize) - 1
      complete = canvas.function

    clear: ->
      ctx = @canvas.getContext '2d'
      ctx.clearRect 0, 0, @canvas.width, @canvas.height

    draw: =>
      requestAnimationFrame @draw
      @clear()
      @drawGrid()
      @drawNotes()

    drawGrid: ->
      ctx = @canvas.getContext '2d'
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)'

      for row in [0...@numRows]
        offset =  (1 + row) * @cellSize
        ctx.beginPath()
        ctx.moveTo 0, offset
        ctx.lineTo @canvas.width, offset
        ctx.lineWidth = 1
        ctx.stroke()

      for col in [0...@numColumns]
        offset =  (1 + col) * @cellSize
        ctx.beginPath()
        ctx.moveTo offset, 0
        ctx.lineTo offset, @canvas.height
        ctx.lineWidth = if col % 4 is 0 then 2 else 1
        ctx.stroke()

    drawNotes: ->
      for col of @state
        for row of @state[col]
          if @state[col][row]
            @drawNote row, col

      drawNote: (row, col) ->
        ctx = @canvas.getContext '2d'
        if @state[col][row]
          ctx.fillStyle = '#fa435f'
        else
          ctx.fillStyle = 'rgb(255, 255, 255)'
        x = col * @cellSize + @cellSize
        y = row * @cellSize + @cellSize
        radius = 3
        ctx.beginPath()
        ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
        ctx.fill()

      highlightcolumn: (col, color) ->
        ctx = @canvas.getContext '2d'
        ctx.fillStyle = color or 'rgba(0, 0, 255, 0.8)'
        ctx.lineWidth = 4
        x = col * @cellSize + @cellSize
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
        if @current == Math.floor(position.left / @cellSize) + 1
          @current = Math.floor($("#left").width()/@cellSize)

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
        row = Math.round(coords.y / @cellSize) - 1
        col = Math.round(coords.x / @cellSize) - 1
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
        steps: Session.get("steps")
        bpm: Session.get('bpm')

      buildLib: (exportObject) ->
        Meteor.call("createClip", exportObject)

      import: (clip) ->
        Session.set 'bpm', clip.bpm
        @steps = clip.steps
        pitches = (note.sound for note in clip.notes)
        @noteMin = Math.min(pitches...)
        @noteMax = Math.max(pitches...)
        @reset()

        for note in clip.notes
          tickLength = note.stop - note.start
          col = note.start / tickLength
          row = @getRow note.sound
          if @state[col]? and @state[col][row]?
            @state[col][row] = true

