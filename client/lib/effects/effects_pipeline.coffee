class EffectsPipeline
  constructor: ->
    @input = App.audioContext.createGainNode()
    @output = App.audioContext.createGainNode()
    @effects = []
    @reset()

  reset: ->
    for effect in @effects
      effect.disconnect()
      klass = effect["name"].toLowerCase()
      $(".#{klass} .knob").trigger "configure",
        fgColor: "#085354"

    @last = @input
    @last.connect @output

  addEffect: (effect) ->
    @last.disconnect @output
    @last.connect effect.input
    @effects.push effect
    effect.connect @output
    @last = effect

  connect: (target) ->
    @output.connect target
