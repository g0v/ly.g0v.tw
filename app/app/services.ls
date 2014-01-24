TWLYMapping = do
  '孔文吉': 1312
  '田秋堇': 1316
  '吳育昇': 1322
  '吳秉叡': 1324
  '李昆澤': 1327
  '林淑芬': 1337
  '林滄敏': 1338
  '林鴻池': 1340
  '張慶忠': 1347
  '費鴻泰': 1365
  '黃志雄': 1366
  '黃偉哲': 1367
  '管碧玲': 1374
  '潘孟安': 1376
  '蔡其昌': 1377
  '蔡錦隆': 1380
  '薛凌': 1384
  '謝國樑': 1387
  '羅淑蕾': 1638
  '王進士': 1701
  '林明溱': 1706
  '陳亭妃': 1708
  '陳節如': 1709
  '廖正井': 1711
  '鄭汝芬': 1713
  '盧嘉辰': 1715
  '簡東明': 1717
  '蘇震清': 1718
  '張嘉郡': 1719
  '陳淑慧': 1720
  '蔣乃辛': 1722
  '劉建國': 1723
  '馬文君': 1724
  '王廷升': 1727
  '王育敏': 1728
  '王惠美': 1729
  '尤美女': 1730
  '江啟臣': 1731
  '江惠貞': 1732
  '何欣純': 1733
  '吳育仁': 1734
  '吳宜臻': 1735
  '呂玉玲': 1736
  '李俊俋': 1738
  '李貴敏': 1739
  '林世嘉': 1740
  '林佳龍': 1741
  '林國正': 1742
  '邱文彥': 1743
  '邱志偉': 1744
  '姚文智': 1745
  '徐欣瑩': 1747
  '張曉風': 1748
  '許忠信': 1749
  '許智傑': 1750
  '陳雪生': 1751
  '陳碧涵': 1752
  '陳歐珀': 1753
  '陳鎮湘': 1754
  '曾巨威': 1755
  '黃文玲': 1756
  '楊玉欣': 1757
  '楊應雄': 1758
  '楊曜': 1759
  '詹凱臣': 1760
  '趙天麟': 1761
  '劉櫂豪': 1762
  '鄭天財Sra.Kacaw': 1763
  '鄭天財': 1763
  '鄭麗君': 1764
  '蘇清泉': 1765
  '顏寬恒': 1803
  '陳怡潔': 1804
  '葉津鈴': 1805
  '王金平': 22
  '丁守中': 515
  '洪秀柱': 546
  '翁重鈞': 551
  '李慶華': 607
  '柯建銘': 629
  '許添財': 639
  '陳唐山': 645
  '黃昭順': 665
  '潘維剛': 678
  '李應元': 708
  '林郁方': 716
  '徐少萍': 726
  '陳其邁': 734
  '蔡煌瑯': 752
  '林正二': 788
  '陳明文': 828
  '陳根德': 833
  '陳超明': 836
  '陳學聖': 840
  '楊瓊瓔': 854
  '葉宜津': 855
  '賴士葆': 866
  '盧秀燕': 869
  '羅明才': 879
  '呂學樟': 892
  '李桐豪': 896
  '李鴻鈞': 898
  '林岱樺': 904
  '林德福': 908
  '邱議瑩': 913
  '段宜康': 917
  '紀國棟': 918
  '孫大千': 919
  '徐耀昌': 921
  '高志鵬': 923
  '高金素梅': 926
  '楊麗環': 960
  '廖國棟': 962
  '蔡正元': 966
  '顏清標': 979
  '魏明谷': 980
  '蕭美琴': 981

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
  base = 'http://vote.ly.g0v.tw/voter/'
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

