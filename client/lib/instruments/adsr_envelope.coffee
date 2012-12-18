class ADSREnvelope
  constructor: (@attack, @decay, @sustain, @release) ->
    @input = audioContext.createGainNode()
    @output = audioContext.createGainNode()
    @input.connect @output
    @reset 0

  reset: (time) ->
    @output.gain.cancelScheduledValues time
    @output.gain.setValueAtTime 0, time

  start: (time) ->
    @reset time
    @output.gain.linearRampToValueAtTime 1, time + @attack
    @output.gain.linearRampToValueAtTime @sustain, time + @attack + @decay

  stop: (time) ->
    @output.gain.cancelScheduledValues time
    @output.gain.linearRampToValueAtTime 0, time + @release

  connect: (target) ->
    @output.connect target
