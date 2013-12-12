TWLYMapping = do
  '詹凱臣': 19
  '吳育仁': 12
  '徐少萍': 6
  '陳淑慧': 26
  '洪秀柱': 35
  '蘇清泉': 29
  '李貴敏': 1
  '潘維剛': 28
  '曾巨威': 81
  '陳碧涵': 14
  '王育敏': 46
  '楊玉欣': 97
  '紀國棟': 17
  '邱文彥': 11
  '陳鎮湘': 3
  '王金平': 92
  '葉津鈴': 116
  '黃文玲': 9
  '許忠信': 7
  '李應元': 69
  '蕭美琴': 96
  '鄭麗君': 68
  '柯建銘': 73
  '吳宜臻': 61
  '陳節如': 67
  '尤美女': 4
  '薛凌': 62
  '田秋堇': 70
  '蔡煌瑯': 84
  '段宜康': 41
  '吳秉叡': 33
  '陳其邁': 65
  '李桐豪': 90
  '陳怡潔': 115
  '林明溱': 87
  '馬文君': 101
  '蔡錦隆': 111
  '顏寬恒': 114
  '盧秀燕': 112
  '楊瓊瓔': 109
  '江啟臣': 72
  '蔡其昌': 56
  '林佳龍': 55
  '何欣純': 98
  '羅淑蕾': 25
  '蔡正元': 105
  '林郁方': 76
  '費鴻泰': 103
  '丁守中': 32
  '賴士葆': 39
  '蔣乃辛': 49
  '姚文智': 37
  '陳亭妃': 40
  '陳唐山': 63
  '黃偉哲': 48
  '許添財': 93
  '葉宜津': 77
  '劉櫂豪': 64
  '李俊俋': 66
  '翁重鈞': 23
  '陳明文': 106
  '謝國樑': 113
  '陳歐珀': 94
  '王進士': 83
  '潘孟安': 54
  '蘇震清': 82
  '孔文吉': 34
  '簡東明': 50
  '高金素梅': 36
  '鄭天財': 38
  '廖國棟': 8
  '王惠美': 20
  '林滄敏': 74
  '鄭汝芬': 51
  '魏明谷': 95
  '羅明才': 79
  '吳育昇': 85
  '李鴻鈞': 107
  '林鴻池': 52
  '黃志雄': 5
  '盧嘉辰': 30
  '張慶忠': 24
  '江惠貞': 45
  '李慶華': 100
  '林德福': 78
  '高志鵬': 99
  '林淑芬': 60
  '呂學樟': 53
  '徐欣瑩': 10
  '孫大千': 2
  '陳學聖': 89
  '廖正井': 15
  '楊麗環': 47
  '陳根德': 88
  '呂玉玲': 42
  '楊曜': 102
  '王廷升': 86
  '徐耀昌': 16
  '陳超明': 80
  '陳雪生': 22
  '楊應雄': 27
  '張嘉郡': 108
  '劉建國': 71
  '黃昭順': 21
  '林國正': 44
  '管碧玲': 75
  '邱志偉': 58
  '許智傑': 59
  '邱議瑩': 110
  '林岱樺': 43
  '趙天麟': 18
  '李昆澤': 57
  '顏清標': 104
  '張曉風': 31
  '林正二': 91
  '林世嘉': 13

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

.service 'TWLYService': <[$http]> ++ ($http) ->
  base = 'http://twly.herokuapp.com/voter/'
  getLink: (name) ->
      return if TWLYMapping[name] => base + TWLYMapping[name]

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

.service 'LYLaws': <[$q $http $timeout]> ++ ($q, $http, $timeout) ->
  base = "#{window.global.config.APIENDPOINT}v0/collections/laws"
  _laws = []
  init = ->
    {paging, entries} <- $http.get base, do
      params:
        l: 1
    .success
    {paging, entries} <- $http.get base, do
      params:
        l: paging.count
    .success
    for entry in entries
      _laws.push entry

  search-law = (name) ->
    result = []
    for law in _laws
      if law.name .match name and result.length < 7
        result.push law
    return result

  init!

  return do
    get: (name, cb) ->
      result = search-law name
      cb result

