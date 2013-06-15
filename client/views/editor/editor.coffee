class ClipEditor
  constructor: (params) ->
    @initializeCanvas(params.canvas)

  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $(canvas).parent().height()
    @canvas.width = $(canvas).parent().width()
    @resize()

  resize: ->
    height = $("#effects").position().top
    $("#editor-canvas").css "height", height - 2

Template.editor.rendered = ->
  canvas = $("#clip-editor canvas")
  App.editor ?= new ClipEditor
    canvas: canvas

  $(window).resize ->
    App.editor.resize()

# Template.editor.events
