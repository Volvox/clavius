addEffect = (e) ->
  App.effects =
    wahwah: new App.tuna.WahWah(automode: false)
    delay: new App.tuna.Delay()
    overdrive: new App.tuna.Overdrive()
    chorus: new App.tuna.Chorus()
    reverb: new App.tuna.Convolver(impulse: "/impulses/impulse_rev.wav")
    phaser: new App.tuna.Phaser(rate: 3.5)

  for klass, effect of App.effects
    if e.hasClass klass
      App.effectsPipeline.addEffect effect, klass

Template.effects.events
  'click i': (e) ->
    $e = $(e.srcElement).parent()
    $e.toggleClass('active')
    if $e.hasClass 'active'
      addEffect $e
    else
      App.effectsPipeline.reset()
      for e in $e.siblings()
        if $(e).hasClass 'active'
          addEffect $(e)
