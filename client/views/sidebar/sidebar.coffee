Template.sidebar.events
  'click li.synthesis': ->
    Session.set 'currentInstrument', 'synthesis'

  'click li.sampler': ->
    Session.set 'currentInstrument', 'sampler'

  'click li.drumkit': ->
    Session.set 'currentInstrument', 'drumkit'

Template.sidebar.helpers
  instrumentIs: (which) ->
    Session.equals('currentInstrument', which)

  instrument: ->
    Session.get("currentInstrument")

Template.sidebar.rendered = ->
  unless Session.get('currentInstrument')
    Session.set 'currentInstrument', 'synthesis'
