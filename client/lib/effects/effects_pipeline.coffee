class EffectsPipeline
  constructor: ->
    @input = App.audioContext.createGainNode()
    @output = App.audioContext.createGainNode()
    @effects = {}
    @reset()

  reset: ->
    for klass, effect of @effects
      effect.disconnect()
      @deactivateKnob klass.toString()
    @last = @input
    @last.connect @output

  activateKnob: (klass) ->
    $(".#{klass} .knob").trigger "configure",
      fgColor: "#0f979a"

  deactivateKnob: (klass) ->
    $(".#{klass} .knob").trigger "configure",
      fgColor: "#085354"

  addEffect: (effect, klass) ->
    @last.disconnect @output
    @last.connect effect.input
    @activateKnob klass
    @effects[klass] = effect
    effect.connect @output
    @last = effect

  connect: (target) ->
    @output.connect target
