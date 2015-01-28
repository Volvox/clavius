class @SessionManager # TODO: come up with a reasonable name for this
  constructor: (params) ->
    @$el = params.el
    @gridSize = params.gridSize
    @clips = []
    @resize()

    @$el.droppable
      drop: (e, ui) =>
        $('#tab-content').css('overflow', 'auto')
        row = @getRow ui.offset.top
        col = @getCol ui.offset.left
        clip = ui.helper.data 'clip'
        @add clip, row, col

    @$el.click (e) =>
      row = @getRow e.pageY
      col = @getCol e.pageX
      @toggleClip row, col

  resize: ->
    @rows = Math.floor(@$el.height() / @gridSize)
    @cols = Math.floor(@$el.width() / @gridSize)
    _.each [0...@rows * @cols], (index) =>
        @$el.append Blaze.toHTMLWithData(Template.session_clip, width: @gridSize, height: @gridSize)
        if (index) == (@rows * @cols) - 1
          @render()

  add: (clip, row, col) ->
    index = row * @cols + col
    @clips[index] = clip
    @$el.children().eq(row * @cols + col).addClass 'active'

  get: (row, col) ->
    @clips[row * @cols + col]

  getRow: (offsetTop) ->
    Math.min(Math.floor(((offsetTop - @$el.offset().top) / @$el.height()) * @rows), @rows - 1)

  getCol: (offsetLeft) ->
    Math.min(Math.floor(((offsetLeft - @$el.offset().left) / @$el.width()) * @cols), @cols - 1)

  render: (callback) ->
    _.each [0...@rows * @cols], (index) =>
      @renderClip index
      if (index) == (@rows * @cols) - 1
        @draw()

  renderClip: (index) ->
    clip = @clips[index]
    if clip?
      params = _.extend clip,
        width: @gridSize
        height: @gridSize
      @$el.children(index).eq().replaceWith Template.session_clip(params)

  draw: =>
    requestAnimationFrame @draw
    _.each [0...@rows * @cols], (index) =>
      @drawClip index

  drawClip: (index) =>
    clip = @clips[index]
    el = @$el.children().eq(index)
    canvas = el.children('canvas')[0]
    radius = Math.min(canvas.width, canvas.height) * 0.45
    ctx = canvas.getContext '2d'
    ctx.clearRect 0, 0, canvas.width, canvas.height
    ctx.setLineDash [2, 2]
    ctx.lineWidth = 2
    if clip?
      if clip.playing()
        ctx.strokeStyle = 'rgb(0, 189, 129)'
      else
        ctx.strokeStyle = 'rgb(15, 151, 154)'
      if clip.nextTime? and clip.nextTime > App.audioContext.currentTime
        # before next action
        ctx.strokeStyle = 'rgb(253, 238, 137)'
    else
      ctx.strokeStyle = 'rgb(50, 50, 70)'
    ctx.beginPath()
    ctx.arc canvas.width / 2, canvas.height / 2, radius, 0, 2 * Math.PI, true
    ctx.stroke()

  toggleClip: (row, col) ->
    clip = @get row, col
    if clip?
      if clip.playing()
        @$el.children().eq(row * @cols + col).removeClass 'playing'
        clip.stop(App.metronome.measure(1))
      else
        @$el.children().eq(row * @cols + col).addClass 'playing'
        clip.start(App.metronome.measure(1), true)

Template.session.rendered = ->
  App.session ?= new SessionManager
    el: $('#session')
    gridSize: 100

