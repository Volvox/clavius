class @Input
  constructor: (params) ->
    params = params or {}
    @noteOn = params.noteOn or (note) -> console.log "noteOn: #{note}"
    @noteOff = params.noteOff or (note) -> console.log "noteOff: #{note}"
