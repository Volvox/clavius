class Timeline
        # @song = Session.get "song"

    render: (canvas) ->
        canvas.height = $(canvas).height()
        canvas.width = $(canvas).width()
        ctx = canvas.getContext '2d'
        notches = Math.round(canvas.width / 10)

        for notch in [0...notches]

            offset = notch * 400
            ctx.lineWidth = 3
            ctx.beginPath()
            ctx.moveTo offset, 0
            ctx.lineTo offset, 20
            ctx.strokeStyle = "#000"
            ctx.stroke()

        ctx.beginPath()
        ctx.lineTo 0, canvas.width
        ctx.strokeStyle = "#000"
        ctx.stroke()


Template.timeline_canvas.rendered = ->
    unless window.timeline?
        canvas = @find('#timeline_canvas')
        window.timeline = new Timeline()
        timeline.render canvas
        console.log timeline

# Template.timeline_canvas.events
#     'change '