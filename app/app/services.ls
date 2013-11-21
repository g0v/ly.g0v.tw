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
    parseParty: (n) ->
      party = match n
      | \中國國民黨     => \KMT
      | \國民黨     => \KMT
      | \民主進步黨     => \DPP
      | \民進黨     => \DPP
      | \台灣團結聯盟   => \TSU
      | \台灣團結聯盟   => \TSU
      | \無黨團結聯盟   => \NSU
      | \親民黨         => \PFP
      | \新黨           => \NP
      | \建國黨         => \TIP
      | \超黨派問政聯盟 => \CPU
      | \民主聯盟       => \DU
      | \新國家陣線     => \NNA
      | /無(黨籍)?/     => null
      | \其他           => null
      else => console.error it
      party



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
