addEffect = (e) ->
  effects =
    wahwah: new tuna.WahWah(automode: false)
    delay: new tuna.Delay()
    overdrive: new tuna.Overdrive()
    chorus: new tuna.Chorus()
    reverb: new tuna.Convolver(impulse: "/impulses/impulse_rev.wav")
    phaser: new tuna.Phaser(rate: 3.5)

  for klass, effect of effects
    if e.hasClass klass
      effectsPipeline.addEffect effect

Template.effects.rendered = ->
  $('.amount .tick').addClass('active')

Template.effects.events
  'click .name': (e) ->
    $e = $(e.srcElement).parent()
    $e.toggleClass('active')

    if $e.hasClass 'active'
      addEffect $e
    else
      effectsPipeline.reset()
      for e in $e.siblings()
        if $(e).hasClass 'active'
          addEffect $(e)

  'click .tick': (e) ->
    $(e.srcElement).addClass('active')
    index = $(e.srcElement).index() - 1
    $(e.srcElement).siblings().each (i, e) ->
      if i > index
        $(e).removeClass('active')
      else
        $(e).addClass('active')

