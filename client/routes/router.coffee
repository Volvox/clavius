ClaviusRouter = Backbone.Router.extend
  routes:
    ":route": "main"
  main: (route) ->
    switch route
      when "sequencer"
        Session.set "current_page", "stepsequencer"
      else
        Session.set "current_page", "mixer"

Router = new ClaviusRouter

Meteor.startup ->
  Backbone.history.start
    pushState: true
