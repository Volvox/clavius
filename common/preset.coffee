Presets = new Meteor.Collection('presets')

validInstruments = ['drumkit', 'prodigy']

Meteor.methods
  createPreset: (data) ->
    data ?= {}
    if data.instrument in validInstruments and data.params?
      Presets.insert data
      null
