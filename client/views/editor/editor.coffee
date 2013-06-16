class ClipEditor
  constructor: (params) ->
    @initializeCanvas(params.canvas)
    @initializeTooltip()
    @draw()

  initializeCanvas: (canvas) =>
    @resize()
    @canvas = canvas
    @canvas.height = $(canvas).parent().height() -  $("#options").height()
    @canvas.width = $(canvas).parent().width() + 15
    @cellWidth = 30
    @numColumns = (@canvas.width/@cellWidth) - 3
    @numRows = Math.floor( @canvas.height / (@cellWidth/2) )

  initializeTooltip: ->
    $("[rel='tooltip']").tooltip
      placement: "bottom"

  draw: =>
    requestAnimationFrame @draw
    @drawGrid()

  drawGrid: =>
    ctx = @canvas.getContext "2d"
    color = 'hsl(258, 42%, 13%)'
    for row in [0...@numRows]
      for col in [0...@numColumns]
        ctx.beginPath()
        offset = (col + 0.5) * @cellWidth
        ctx.rect(offset*1.1, row*(@cellWidth/1.7), @cellWidth, @cellWidth/2)
        ctx.fillStyle = color
        ctx.fill()

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

Template.editor.rendered = ->
  App.editor ?= new ClipEditor
    canvas: $("#clip-editor canvas")[0]

  $(window).resize ->
    App.editor.resize()

Template.editor.events
  "click #clip-editor li": (e) ->
    action = $(e.srcElement).attr "data-original-title"
    switch action
      when "toggle FX" then App.editor.toggleEffects()
