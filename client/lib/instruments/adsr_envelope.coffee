class @ADSREnvelope
  constructor: (@target, params) ->
    params ?= {}
    @attack = params.attack ? 0.01
    @decay = params.decay ? 0.05
    @sustain = params.sustain ? 0.97
    @release = params.release ? 0.23
    @max = params.max ? 1
    @min = params.min ? 0
    @reset 0

  setADSR: (attack, decay, sustain, release) ->
    @attack = attack
    @decay = decay
    @sustain = sustain
    @release = release

  reset: (time) ->
    @target.cancelScheduledValues time
    @target.setValueAtTime @min, time

  start: (time) ->
    @reset time
    @target.linearRampToValueAtTime @max, time + @attack
    @target.linearRampToValueAtTime @sustain * @max, time + @attack + @decay

  stop: (time) ->
    @target.cancelScheduledValues time
    @target.linearRampToValueAtTime @min, time + @release
