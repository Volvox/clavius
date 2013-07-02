@searchFreesound = (params, callback) ->
  $.ajax
    url: "http://www.freesound.org/api/sounds/search?api_key=ec0c281cc7404d14b6f5216f96b8cd7c"
    data: params
    dataType: "jsonp"
    error: (e) ->
      console.log(e)
    success: (data) =>
      callback data.sounds

@getFreesoundSample = (soundId, callback) ->
  $.ajax
    url: "http://www.freesound.org/api/sounds/#{soundId}?api_key=ec0c281cc7404d14b6f5216f96b8cd7c"
    dataType: "jsonp"
    error: (e) ->
      console.log(e)
    success: (data) =>
      callback data

