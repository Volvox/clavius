Template.prodigy.rendered = ->
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
    button = new OscillatorButton(canvas, 2, 'rgb(24, 207, 255)')
    $(canvas).click ->
      button.wave += 1
      button.wave %= 4
      button.draw()
