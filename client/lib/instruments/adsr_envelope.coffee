class ADSREnvelope
  constructor: (@target, params) ->
    params ?= {}
    @attack = params.attack ? 0
    @decay = params.decay ? 0
    @sustain = params.sustain ? 1
    @release = params.release ? 0
    @max = params.max ? 1
    @min = params.min ? 0
    @reset 0

  reset: (time) ->
    @target.cancelScheduledValues time
    @target.setValueAtTime @min, time

  start: (time) ->
    @reset time
    @target.linearRampToValueAtTime @max, time + @attack
    @target.linearRampToValueAtTime @sustain, time + @attack + @decay

  stop: (time) ->
    @target.cancelScheduledValues time
    @target.linearRampToValueAtTime @min, time + @release
