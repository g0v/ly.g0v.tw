# Services

# Create an object to hold the module.
mod = LYService: <[$http]> ++ ($http) ->
    mly = []
    $http.get '/data/mly-8.json' .success -> mly := it
    do
        resolveParty: (n) ->
            [party] = [party for {party,name} in mly when name is n]
            party

angular.module 'app.services' [] .factory mod
.service 'LYModel': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
    base = 'http://api-beta.ly.g0v.tw/v0/collections/'
    _model = {}

    localGet = (key) ->
      deferred = $q.defer!
      promise = deferred.promise
      promise.success = (fn) ->
        promise.then (rsp) ->
          fn rsp
      promise.error = (fn) ->
        promise.then (rsp) ->
          fn rsp
      $timeout ->
        console.log \useLocalCache
        deferred.resolve _model[key]
      return promise

    wrapHttpGet = (key, url, params) ->
      req = $http.get url, params
      [_success, _error] = [req.success, req.error]
      req.success = (fn) ->
        rsp <- _success
        console.log 'save response to local model'
        _model[key] = rsp
        fn rsp
      req.error = (fn) ->
        rsp <- _error
        fn rsp
      return req

    return do
      get: (path, params) ->
        url = base + path
        if params => key = url + JSON.stringify params else key = url
        key = key - /\"/g
        if _model.hasOwnProperty key
          return localGet key
        else
          return wrapHttpGet key, url, params

