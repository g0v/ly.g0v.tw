angular.module 'app.services' []
.factory LYService: <[$http]> ++ ($http) ->
  mly = []
  do
    init: ->
      $http.get '/data/mly-8.json' .success -> mly := it
    resolveParty: (n) ->
      [party] = [party for {party,name} in mly when name is n]
      party
    resolve-party-color: (n) -> {KMT: \#000095 DPP: \#009a00 PFP: \#fe6407}[@resolve-party n] or \#999

.service 'LYModel': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
    base = "#{window.global.config.APIENDPOINT}v0/collections/"
    _model = {}

    localGet = (key) ->
      deferred = $q.defer!
      promise = deferred.promise
      promise.success = (fn) ->
        promise.then fn
      promise.error = (fn) ->
        promise.then fn
      $timeout ->
        console.log \useLocalCache
        deferred.resolve _model[key]
      return promise

    wrapHttpGet = (key, url, params) ->
      {success, error}:req = $http.get url, params
      req.success = (fn) ->
        rsp <- success
        console.log 'save response to local model'
        _model[key] = rsp
        fn rsp
      req.error = (fn) ->
        rsp <- error
        fn rsp
      return req

    return do
      get: (path, params) ->
        url = base + path
        key = if params => url + JSON.stringify params else url
        key -= /\"/g
        return if _model.hasOwnProperty key
          localGet key
        else
          wrapHttpGet key, url, params
