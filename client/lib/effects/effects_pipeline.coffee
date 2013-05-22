class EffectsPipeline
  constructor: ->
    @input = App.audioContext.createGainNode()
    @output = App.audioContext.createGainNode()
    @effects = []
    @reset()

  reset: ->
    for effect in @effects
      effect.disconnect()

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
