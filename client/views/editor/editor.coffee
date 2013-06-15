class ClipEditor
  constructor: (params) ->
    @initializeCanvas(params.canvas)
    @initializeTooltip()

  initializeCanvas: (canvas) ->
    @canvas = canvas
    @canvas.height = $(canvas).parent().height()
    @canvas.width = $(canvas).parent().width()
    @resize()

  initializeTooltip: ->
    $("[rel='tooltip']").tooltip
      placement: "bottom"

  resize: ->
    height = $("#effects").position().top
    $("#editor-canvas").css "height", height - 2

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
  canvas = $("#clip-editor canvas")
  App.editor ?= new ClipEditor
    canvas: canvas

  $(window).resize ->
    App.editor.resize()

Template.editor.events
  "click #clip-editor li": (e) ->
    action = $(e.srcElement).attr "data-original-title"
    switch action
      when "toggle FX" then App.editor.toggleEffects()
