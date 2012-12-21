Presets = new Meteor.Collection('presets')

validInstruments = ['drumkit']

Meteor.methods
  createPreset: (data) ->
    data ?= {}
    if data.instrument in validInstruments and data.params?
      Presets.insert data
      null
