Template.effects.rendered = ->
  $('.effect').addClass('active')
  $('.amount .tick').addClass('active')

Template.effects.events
  'click .name': (e) ->
    $(e.srcElement).parent().toggleClass('active')
  'click .tick': (e) ->
    $(e.srcElement).addClass('active')
    index = $(e.srcElement).index() - 1
    $(e.srcElement).siblings().each (i, e) ->
      if i > index
        $(e).removeClass('active')
      else
        $(e).addClass('active')

