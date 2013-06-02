controls = [
  'osc1Mix',
  'osc1Detune',
  'osc1Octave',
  'modOsc1',
  'osc2Mix',
  'osc2Detune',
  'osc2Octave',
  'modOsc2',
  null,
  null,
  'modFrequency',
  'modOscFrequencyMultiplier',
  'filterCutoff',
  'filterQ',
  'filterMod',
  'filterEnv',
]

randomize = ->
  $('.knob').each (i, knob) ->
    min = $(knob).data 'min'
    max = $(knob).data 'max'
    val = (min + Math.random() * (max - min))
    $(knob)
      .val(val)
      .trigger('change')
    App.instrument.params[controls[i]] = val
  return true

Template.prodigy.events
  'change .presets-dropdown select': () ->
    randomize()
    $(this).blur()

  'click .presets button': (e) ->
    randomize()

Template.prodigy.rendered = ->
  setInstrument(new ProdigySynthesizer())

  $(".knob").knob
    draw: ->
      # "tron" case
      if @$.data("skin") is "tron"
        a = @angle(@cv) # Angle
        sa = @startAngle # Previous start angle
        sat = @startAngle # Start angle
        ea = undefined
        # Previous end angle
        eat = sat + a # End angle
        r = true
        @g.lineWidth = @lineWidth
        @o.cursor and (sat = eat - 0.3) and (eat = eat + 0.3)
        if @o.displayPrevious
          ea = @startAngle + @angle(@value)
          @o.cursor and (sa = ea - 0.3) and (ea = ea + 0.3)
          @g.beginPath()
          @g.strokeStyle = @previousColor
          @g.arc @xy, @xy, @radius - @lineWidth, sa, ea, false
          @g.stroke()
        @g.beginPath()
        @g.strokeStyle = (if r then @o.fgColor else @fgColor)
        @g.arc @xy, @xy, @radius - @lineWidth, sat, eat, false
        @g.stroke()
        @g.lineWidth = 2
        @g.beginPath()
        @g.strokeStyle = @o.fgColor
        @g.arc @xy, @xy, @radius - @lineWidth + 1 + @lineWidth * 2 / 3, 0, 2 * Math.PI, false
        @g.stroke()
        false

  $('.osc canvas').each (i, canvas) ->
    switch i
      when 0 then wave = App.instrument.params.osc1Waveform
      when 1 then wave = App.instrument.params.osc2Waveform
      when 2 then wave = App.instrument.params.modWaveform
    button = new OscillatorButton(canvas, wave, 'rgb(15, 151, 154)')
    $(canvas).click ->
      button.wave += 1
      button.wave %= 4
      button.draw()
      switch i
        when 0 then App.instrument.params.osc1Waveform = button.wave
        when 1 then App.instrument.params.osc2Waveform = button.wave
        when 2 then App.instrument.params.modWaveform = button.wave

  # osc 1 #
  $('.osc1 .knobs .mix').trigger 'configure',
    change: (v) ->
      App.instrument.params.osc1Mix = v
  $('.osc1 .knobs .mix').val(App.instrument.params.osc1Mix).trigger('change')

  $('.osc1 .knobs .detune').trigger 'configure',
    min: -100
    max: 100
    change: (v) ->
      App.instrument.params.osc1Detune = v
  $('.osc1 .knobs .detune').val(App.instrument.params.osc1Detune).trigger('change')

  $('.osc1 .knobs .octave').trigger 'configure',
    min: 0
    max: 3
    change: (v) ->
      App.instrument.params.osc1Octave = v
  $('.osc1 .knobs .octave').val(App.instrument.params.osc1Octave).trigger('change')

  $('.osc1 .knobs .mod').trigger 'configure',
    change: (v) ->
      App.instrument.params.modOsc1 = v
  $('.osc1 .knobs .mod').val(App.instrument.params.modOsc1).trigger('change')

  # osc 2 #
  $('.osc2 .knobs .mix').trigger 'configure',
    change: (v) ->
      App.instrument.params.osc2Mix = v
  $('.osc2 .knobs .mix').val(App.instrument.params.osc2Mix).trigger('change')

  $('.osc2 .knobs .detune').trigger 'configure',
    min: -100
    max: 100
    change: (v) ->
      App.instrument.params.osc2Detune = v
  $('.osc2 .knobs .detune').val(App.instrument.params.osc2Detune).trigger('change')

  $('.osc2 .knobs .octave').trigger 'configure',
    min: 0
    max: 3
    change: (v) ->
      App.instrument.params.osc2Octave = v
  $('.osc2 .knobs .octave').val(App.instrument.params.osc2Octave).trigger('change')

  $('.osc2 .knobs .mod').trigger 'configure',
    change: (v) ->
      App.instrument.params.modOsc2 = v
  $('.osc2 .knobs .mod').val(App.instrument.params.modOsc2).trigger('change')

  # mod osc #
  $('.modOsc .knobs .frequency').trigger 'configure',
    change: (v) ->
      App.instrument.params.modFrequency = v
  $('.modOsc .knobs .frequency').val(App.instrument.params.modFrequency).trigger('change')

  $('.modOsc .knobs .multiplier').trigger 'configure',
    min: 1
    change: (v) ->
      App.instrument.params.modOscFreqMultiplier = v
  $('.modOsc .knobs .multiplier').val(App.instrument.params.modOscFreqMultiplier).trigger('change')

  # filter #
  $('.filter .knobs .cutoff').trigger 'configure',
    min: 0.0
    max: 1000.0
    change: (v) ->
      App.instrument.params.filterCutoff = v
  $('.filter .knobs .cutoff').val(App.instrument.params.filterCutoff).trigger('change')

  $('.filter .knobs .q').trigger 'configure',
    min: 0.01
    max: 20.0
    change: (v) ->
      App.instrument.params.filterQ = v
  $('.filter .knobs .q').val(App.instrument.params.filterQ).trigger('change')

  $('.filter .knobs .mod').trigger 'configure',
    change: (v) ->
      App.instrument.params.filterMod = v
  $('.filter .knobs .mod').val(App.instrument.params.filterMod).trigger('change')

  $('.filter .knobs .env').trigger 'configure',
    change: (v) ->
      App.instrument.params.filterEnv = v
  $('.filter .knobs .env').val(App.instrument.params.filterEnv).trigger('change')

Template.prodigy.events
  "click i": (e) ->
    $e = $(e.srcElement).parent()
    $e.toggleClass('active')