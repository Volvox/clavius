Meteor.Router.add
  '/': 'mixer'
  '/sequencer': 'stepsequencer'

Meteor.startup ->
  Meteor.autorun ->
    Meteor.Router.page()
