committees = do
    IAD: \內政
    FND: \外交及國防
    ECO: \經濟
    FIN: \財政
    EDU: \教育及文化
    TRA: \交通
    JUD: \司法及法制
    SWE: \社會福利及衛生環境
    PRO: \程序

renderCommittee = (committee) ->
    return '院會' unless committee?
    return '院會' if committee is \null # orz, we got stringified version at filter
    committee = [committee] unless $.isArray committee
    res = for c in committee
        """<img class="avatar small" src="http://avatars.io/50a65bb26e293122b0000073/committee-#{c}?size=small" alt="#{committees[c]}">""" + committees[c]
    res.join ''

# for safari. new Date "some-date-string" failed in safari, so do it manually
date-parse = (v) ->
  v = v.replace(/[-:]/g, " ")split " "
  new Date(v.0, v.1 - 1, v.2, v.3, v.4, v.5 )

dowave = (wave, clips, cb) ->
  margin = top:10, left: 70, right: 30, bottom: 50
  w = 960 - margin.left - margin.right
  h = 100 - margin.top - margin.bottom

  parseDate = d3.time.format "%YM%m" .parse;

  svg = d3.select("svg.waveform").text('')
    .attr "width", w + margin.left + margin.right
    .attr "height", h + margin.top + margin.bottom
    .on \click ->
      x0 = x.invert d3.mouse(@).0
      cb x0

    .append "g"
    .attr "transform", "translate(#{margin.left},#{margin.top})"

  chapter = [
  ]

  chapter.forEach -> it.date = parseDate it.date

  x = d3.scale.linear!range [0, w]
    .domain [0, wave.length]
  y = d3.scale.linear!range [h, 0]
    .domain [0, d3.max wave]

  dowave.set-loc = (v) ->
    d3.select \#location-marker .attr \transform -> "translate(#{x v} 0)"

  xAxis = d3.svg.axis!scale x .orient "bottom"
    .tickFormat ->
      [h,m,s] = [parseInt(it / 3600) % 60, parseInt(it / 60) % 60, it % 60]map -> (it>9 and "#{it}") or  "0#{it}"
      "#h:#m:#s"

  area = d3.svg.area!
    .interpolate "basic"
    .x (d,i) -> x i
    .y0 h
    .y -> y it

  svg.append "g"
    .attr "class", "x axis"
    .attr "transform", "translate(0,#h)"
    .call xAxis

  svg.append "path"
    .datum wave
    .attr "d" area
    .style \stroke \black
    .style \fill \steelblue

  svg.append \path
    .attr \id \location-marker
    .attr \d, "M0 0L0,40"
    .attr \stroke, \#f00
    .attr \stroke-width, \2px
  svg.selectAll \g.avatar .data clips .enter!append \g
      ..attr \class \avatar
      ..attr \transform -> "translate(#{x it.offset / 1000} 0)"
      ..append \image
        .attr \class "avatar small"
        .attr \width 10
        .attr \height 10
        .attr \xlink:href ->
          avatar = CryptoJS.MD5 "MLY/#{it.mly}" .toString!
          "http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small"
        .attr \alt -> it.speaker
      ..append \rect
        .attr \width 10
        .attr \height 10
        .style \stroke \steelblue
        .style \stroke-width \1px
        .style \fill \none

angular.module 'app.controllers' []
.controller AppCtrl: <[$scope $location $rootScope]> ++ (s, $location, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

.filter \committee, -> renderCommittee

.controller LYCalendar: <[$rootScope $scope $http LYService]> ++ ($rootScope, $scope, $http, LYService) ->
    # XXX: unused.  use filter instead
    $scope.type = 'sitting'
    $rootScope.activeTab = \calendar
    $scope.committee = ({{committee}:entity}, col) ->
        return '院會' unless committee
        res = for c in committee
            """<img class="avatar small" src="http://avatars.io/50a65bb26e293122b0000073/committee-#{c}?size=small" alt="#{committees[c]}">""" + committees[c]
        res.join ''

    $scope.chair = ({{chair}:entity}, col) ->
        return '' unless chair
        party = LYService.resolveParty chair
        avatar = CryptoJS.MD5 "MLY/#{chair}" .toString!
        chair + """<img class="avatar small #party" src="http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small" alt="#{chair}">"""

    $scope.onair = ({{date,time}:entity}) ->
        d = moment date .startOf \day
        return false unless +today is +d
        [start, end] = time.split \~ .map -> moment "#{d.format 'YYYY-MM-DD'} #it"
        start <= moment! <= end

    $scope.gridOptions = {+showFilter, +showColumnMenu, +showGroupPanel, +enableHighlighting,
    -groupsCollapsedByDefault, +inlineAggregate, +enableRowSelection} <<< do
        groups: <[primaryCommittee]>
        rowHeight: 65
        data: \calendar
        i18n: \zh-tw
        aggregateTemplate: """
        <div ng-click="row.toggleExpand()" ng-style="rowStyle(row)" class="ngAggregate" ng-switch on="row.field">
          <span ng-switch-when="primaryCommittee" class="ngAggregateText" ng-bind-html-unsafe="row.label | committee"></span>
          <span ng-switch-default class="ngAggregateText">{{row.label CUSTOM_FILTERS}} ({{row.totalChildren()}} {{AggItemsLabel}})</span>
          <div class="{{row.aggClass()}}"></div>
        </div>
        """
        columnDefs:
          * field: 'primaryCommittee'
            visible: false
            displayName: \委員會
            width: 130
            cellTemplate: """
            <div ng-bind-html-unsafe="row.getProperty(col.field) | committee"></div>
            """
          * field: 'committee'
            visible: false
            displayName: \委員會
            width: 130
            cellTemplate: """
            <div ng-bind-html-unsafe="row.getProperty(col.field) | committee"></div>
            """
          * field: 'chair'
            displayName: \主席
            width: 130
            cellTemplate: """
            <div ng-bind-html-unsafe="chair(row)"></div>
            """
          * field: 'date'
            cellFilter: 'date: mediumDate'
            width: 100px
            displayName: \日期
          * field: 'time'
            width: 100px
            displayName: \時間
            cellTemplate: """<div ng-class="{onair: onair(row)}"><div class="ngCellText">{{row.getProperty(col.field)}}</div></div>'}]
            """
          * field: 'name'
            displayName: \名稱
            width: 320px
          * field: 'summary'
            displayName: \議程
            cellClass: \summary
            width: '*'

    $scope.$watch 'height' (->
        $ '.grid' .height $scope.height - 65
        options = $scope.gridOptions
        options.$gridServices.DomUtilityService.RebuildGrid options.$gridScope, options.ngGrid
    ), false

    today = moment!startOf('day')
    $scope.weeksOpts = []
    # well, 49 is 7 weeks. I just pick the number for no reaseon.
    for i from 0 to 49 by 7
      do ->
        opt = {
          start: moment today .day 0 - i
          end: moment today .day 0 - i + 7
        }
        opt <<< label: opt.start.format "YYYY:  MM-DD" + ' to ' + opt.end.format "MM-DD"
      |> $scope.weeksOpts.push
    $scope.weeks = $scope.weeksOpts[0]
    getData = ->
      [start, end] = [$scope.weeks.start, $scope.weeks.end].map (.format "YYYY-MM-DD")
      $scope.start = $scope.weeks.start .format "YYYY-MM-DD"
      $scope.end = $scope.weeks.end .format "YYYY-MM-DD"
      {paging, entries} <- $http.get 'http://api-beta.ly.g0v.tw/v0/collections/calendar' do
          params: do
              s: JSON.stringify date: 1, time: 1
              q: JSON.stringify do
                  date: $gt: start, $lt: end
                  type: $scope.type
      .success
      $scope.calendar = entries.map -> it <<< primaryCommittee: it.committee?0
    $scope.$watch 'weeks', getData
    $scope.change = !(type) ->
        $scope.type = type
        getData!

.controller LYBills: <[$scope $http $state LYService]> ++ ($scope, $http, $state, LYService) ->
    $scope.$watch '$state.params.billId' ->
      {billId} = $state.params
      {committee}:bill <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/bills/#{billId}"
      .success
      data <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/bills/#{billId}/data"
      .success
      #
      # XXX should be in data already
      if committee
          committee = committee.map -> { abbr: it, name: committees[it] }

  #    history <- $http.get "/data/#{$routeParams.billId}-history.json" .success
  #    console.log content
  #    console.log history
  #    window.bill-history history, $scope
      $scope <<< bill{summary,abstract} <<< do
        committee: committee,
        related: if bill.committee
            data?related?map ([id, summary]) ->
                # XXX: get meta directly with id when we have endpoint
                {id, summary} <<< if [_, mly]? = summary.match /本院委員(.*?)等/
                    party: LYService.resolveParty mly
                    avatar: CryptoJS.MD5 "MLY/#{mly}" .toString!
                    name: mly
                else
                    {}

        sponsors: bill.sponsors?map ->
            party = LYService.resolveParty it
            party: party, name: it, avatar: CryptoJS.MD5 "MLY/#{it}" .toString!
        cosponsors: bill.cosponsors?map ->
            party = LYService.resolveParty it
            party: party, name: it, avatar: CryptoJS.MD5 "MLY/#{it}" .toString!
        setDiff: (diff, version) ->
            idx = [i for n, i in diff.header when n is version]
            base-index = diff.base-index
            c = diff.comment-index
            diff <<< do
                diffnew: version
                diffcontent: diff.content.map (entry) ->
                    comment: entry[c][diff.header[idx].replace /審查會通過條文/, \審查會]?replace /\n/g "<br>\n"
                    diff: diffview do
                        baseTextLines: entry[base-index] or ' '
                        newTextLines: entry[idx] || entry[base-index]
                        baseTextName: diff.header[base-index]
                        newTextName: diff.header[idx]
                        tchar: ""
                        tsize: 0
                        #inline: true
                    .0

        diff: data?content?map (diff) ->
            h = diff.header
            [base-index] = [i for n, i in h when n is /^現行/]
            [c] = [i for n, i in h when n is \說明]

            diff{header,content,name} <<< do
                versions: h.filter (it, i) -> it isnt \說明 and i isnt base-index
                base-index: base-index
                comment-index: c
                diffbase: h[base-index]
                diffnew: h.0
                diffcontent: diff.content.map (entry) ->
                    comment: entry[c][h.0.replace /審查會通過條文/, \審查會]?replace /\n/g "<br>\n"
                    diff: diffview do
                        baseTextLines: entry[base-index] or ' '
                        newTextLines: entry.0 || entry[base-index]
                        baseTextName: h[base-index] ? ''
                        newTextName: h.0
                        tchar: ""
                        tsize: 0
                        #inline: true
                    .0

.controller About: <[$rootScope $http]> ++ ($rootScope, $http) ->
    $rootScope.activeTab = \about

.controller LYMotions: <[$rootScope $scope $state LYService]> ++ ($rootScope, $scope, $state, LYService) ->
    $rootScope.activeTab = \motions
    var has-data
    $scope.session = '8-2'
    $scope.$on \data (_, d) -> $scope.$apply ->
      $scope.data = d
    $scope.$watch '$state.params.sitting' ->
      unless sitting = $state.params.sitting
        $scope.sitting = null
        return
      $scope.$watch \data ->
        return unless it
        $scope.sitting = +sitting
        $scope.setType \announcement
        $scope.setStatus null
    $scope.$on \show (_, sitting, type, status) -> $scope.$apply ->
        $state.transitionTo 'motions.sitting', { session: $scope.session, sitting }
        $scope <<< {sitting, status}
        $scope.setType type
        $scope.setStatus status
    $scope <<< do
        allTypes:
            * key: \announcement
              value: \報告事項
            * key: \discussion
              value: \討論事項
            * key: \exmotion
              value: \臨時提案
        setType: (type) ->
            [data] = [s for s in $scope.data when s.meeting.sitting is $scope.sitting]
            entries = data[type]
            allStatus = [key: \all, value: \全部] ++ [{key: a, value: $scope.statusName a} for a of {[e.status ? \unknown, true] for e in entries}]
            $scope.status = '' unless $scope.status in allStatus.map (.key)
            for e in entries when !e.avatars?
                if e.proposer?match /委員(.*?)(、|等)/
                    party = LYService.resolveParty that.1
                    e.avatars = [party: party, name: that.1, avatar: CryptoJS.MD5 "MLY/#{that.1}" .toString!]
            $scope <<< {type, entries, allStatus}

        setStatus: (s) ->
            s = '' if s is \all
            s = '' if s is \unknown
            $scope.status = s
        statusName: (s) ->
            names = do
                unknown: \未知
                other: \其他
                passed: \通過
                consultation: \協商
                retrected: \撤回
                unhandled: \未處理
                ey: \請行政院研處
                prioritized: \逕付二讀
                committee: \交委員會
                rejected: \退回
                accepted: \查照
            names[s] ? s
    window.loadMotions $scope

.controller LYSittings: <[$scope $http $state LYService]> ++ ($scope, $http, $state, LYService) ->
  $scope.committees = committees
  $scope <<< lists:{}

  $scope.setContext = (ctx) ->
    $scope.context = ctx
    $state.params.sitting = null

  $scope.$watch '$state.params.sitting' ->
    if $state.params.sitting
      console.log 'specified sitting, get context from id of sitting'
      $scope.context = $state.params.sitting.replace /[\d-]/g,''
    else
      console.log 'no specified sitting, use YS as default context if necessary'
      $scope.context = 'YS' if !$scope.context

  $scope.$watch 'context' (newV, oldV)->
    return unless (newV or oldV)
    console.log 'current context is ', $scope.context
    if $scope.lists.hasOwnProperty $scope.context
      $scope.currentList = $scope.lists[$scope.context]
    else
      console.log 'using context that we do not have yet. fetch it '
      loadList!

  loadList = (length) ->
    if committees[$scope.context]
      type = "{\"" + $scope.context + "\"}"
    else
      type = null

    length = 40 if !length
    $scope.loadingList = true
    {entries} <- $http.get 'http://api-beta.ly.g0v.tw/v0/collections/sittings' do
      params: {q:{"ad":8,"committee": type},l:length, f:{"motions":0}}
    .success
    $scope.loadingList = false
    $scope.lists[$scope.context] = entries
    $scope.currentList = $scope.lists[$scope.context]

  $scope.$watch 'currentList' (newV, oldV)->
    return unless $scope.currentList
    matched = [s for {id}:s in $scope.currentList when id is $state.params.sitting]?0
    if matched
      $scope.chosenSitting = matched
    else
      specified = $state.params.sitting
      if specified
        console.log 'user specified a id out of fetched list, use the i and keep drop-down list blank'
        loadSitting specified
      else
        console.log 'user move to a new context, use the lastest sitting by default'
        $scope.chosenSitting = $scope.currentList[0]

  $scope.$watch 'chosenSitting' (newV, oldV)->
    return unless newV
    {id} = $scope.chosenSitting
    loadSitting $scope.chosenSitting.id

  loadSitting = (id) ->
    return if $state.current.name is \sittings.detail.video
    state = if $state.current.name is /^sittings.detail/ => $state.current.name else 'sittings.detail'
    $state.transitionTo 'sittings.detail', { sitting: id }
    $scope.loadingSitting = true
    result <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/sittings" do
      params: {+fo, q: JSON.stringify id: id}
    .success
    $scope.loadingSitting = false
    $scope <<< result
    $scope.data = []
    $scope.data[\announcement] = getMotionsInType result.motions, \announcement
    $scope.data[\discussion] = getMotionsInType result.motions, \discussion
    $scope.data[\exmotion] = getMotionsInType result.motions, \exmotion
    $scope.setType \announcement
  getMotionsInType = (motions, type) ->
    return [m for m in motions when m.motion_class is type]
  $scope <<< do
      allTypes:
          * key: \announcement
            value: \報告事項
          * key: \discussion
            value: \討論事項
          * key: \exmotion
            value: \臨時提案
      setType: (type) ->
          entries = $scope.data[type]
          allStatus = [key: \all, value: \全部] ++ [{key: a, value: $scope.statusName a} for a of {[e.status ? \unknown, true] for e in entries}]
          $scope.status = '' unless $scope.status in allStatus.map (.key)
          for e in entries when !e.avatars?
              if e.proposed_by?match /委員(.*?)(、|等)/
                  party = LYService.resolveParty that.1
                  e.avatars = [party: party, name: that.1, avatar: CryptoJS.MD5 "MLY/#{that.1}" .toString!]
          $scope <<< {type, entries, allStatus}

      setStatus: (s) ->
          s = '' if s is \all
          s = '' if s is \unknown
          $scope.status = s
      statusName: (s) ->
          names = do
              unknown: \未知
              other: \其他
              passed: \通過
              consultation: \協商
              retrected: \撤回
              unhandled: \未處理
              ey: \請行政院研處
              prioritized: \逕付二讀
              committee: \交委員會
              rejected: \退回
              accepted: \查照
          names[s] ? s

  $scope.playFrom = (seconds) ->
    $scope.player.playVideo!
    $scope.player.seekTo seconds
  $scope.$watch '$state.current.name + $state.params.sitting' ->
    if $state.current.name is \sittings.detail.video
      return if $scope.loaded is $state.params.sitting
      $scope.loaded = $state.params.sitting
      videos <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/sittings/#{$state.params.sitting}/videos"
      .success
      whole = [v for v in videos when v.firm is \whole]
      #start = new Date whole.0.time
      #clips = [{offset: new Date(v.time) - start, mly: v.speaker - /\s*委員/, v.length} for v in videos when v.firm isnt \whole]
      start = date-parse whole.0.time
      clips = [{offset: date-parse(v.time) - start, mly: v.speaker - /\s*委員/, v.length} for v in videos when v.firm isnt \whole]
      YOUTUBE_APIKEY = 'AIzaSyDT6AVKwNjyWRWtVAdn86Q9I7HXJHG11iI'
      details <- $http.get "https://www.googleapis.com/youtube/v3/videos?id=#{whole.0.youtube_id}&key=#{YOUTUBE_APIKEY}
     &part=snippet,contentDetails,statistics,status" .success
      [_, h, m, s] = details.items.0.contentDetails.duration.match /^PT(\d+H)?(\d+M)?(\d+S)/
      duration = (parseInt(h) * 60 + parseInt m) * 60 + parseInt s
      done = false
      onPlayerReady = (event) ->
        $scope.player = event.target
      handler = null
      onPlayerStateChange = (event) ->
        # set waveform location indicator
        if event.data is YT.PlayerState.PLAYING and not done
          if handler => clearInterval handler
          timer = {}
            ..sec = $scope.player.getCurrentTime!
            ..start = new Date!getTime! / 1000
            ..rate = $scope.player.getPlaybackRate!
            ..now = 0
          handler := setInterval ->
            timer.now = new Date!getTime! / 1000
            dowave.set-loc timer.sec + (timer.now - timer.start) * timer.rate
          , 10000
        else
          if handler => clearInterval handler
          handler := null
        return
        # XXX demo
        if event.data is YT.PlayerState.PLAYING and not done
          event.target.seekTo 7200
          <- setTimeout _, 6000
          event.target.stopVideo!
          done := true

      if $scope.player
        $scope.player.loadVideoById do
          videoId: whole.0.youtube_id
      else
        <- setTimeout _, 3000ms
        p = new YT.Player 'player' do
          height: '390'
          width: '640'
          videoId: whole.0.youtube_id
          events:
            onReady: onPlayerReady
            onStateChange: onPlayerStateChange
      mkwave = (wave) ->
        newwave = []
        element = document .getElementById 'waveform2'
        wave.forEach (value, key) ->
          newwave.push value/255
        waveform = new Waveform container: element, data: newwave, width: 960, height: 100
        if duration > wave.length
          wave ++= [1 to duration-(wave.length)].map -> 0
        dowave wave, clips, -> $scope.playFrom it
      wave <- $http.get "http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/#{whole.0.wmvid}.json"
      .error -> mkwave []
      .success
      mkwave wave
    else
      # disabled
      $scope.loaded = null

.controller LYSitting: <[$rootScope $scope $http]> ++ ($rootScope, $scope, $http) ->
    data <- $http.get '/data/yslog/ly-4004.json'
        .success
    $rootScope.activeTab = \sitting
    $scope.json = data
    $scope.meta = data.meta
    $scope.meta.map = []

    patterns = {
        "立法院公報": /^立法院公報　/,
        "主席": /^主　+席　/,
        "時間": /^時　+間　/,
        "地點": /^地　+點　/
    }

    data.meta.raw.forEach (v, i, a) ->
        for type,pattern of patterns
            if v.match pattern
                v = v.replace pattern,""
                key = type
                break
            else
                key = ""
        data.meta.map.push {key, value: v}

    $scope.annoucement = []
    $scope.interpellation = {answers: [], questions: [], interpellations: []}
    $scope.interp = []
    parse = (type, content) ->
        switch type
        | \Announcement =>
            $scope.Announcement = content
            for idx,entry of content
                section = {
                    subject: entry.subject,
                    conversation: []
                }

                for [speaker, words] in entry.conversation
                    section.conversation.push {speaker, words}
                $scope.annoucement.push section

        | \Interpellation =>
            for _,[receiver, words] of content.answers
                $scope.interpellation.answers.push {receiver, words}
            for _,[asker, words] of content.questions
                $scope.interpellation.questions.push {asker, words}
            for [type,entries] in content.interpellation when type is \interp
                $scope.interp.push entries
            for [type,entries] in content.interpellation
                if type is \interp or type is \interpdoc or type is \exmotion
                    section = {
                        questioner: entries.0.0,
                        conversation: []
                    }

                    for [speaker, words] in entries
                        section.conversation.push {speaker, words}
                else
                    section = {
                        questioner: null,
                        conversation:[{
                            speaker: type
                            words: entries
                        }]
                    }

                $scope.interpellation.interpellations.push section

        | otherwise =>
            $scope.otherwise = content

    for entry in data.log
        parse ...entry

.controller LYDebates: <[$rootScope $scope $http LYService]> ++ ($rootScope, $scope, $http, LYService) ->
    $rootScope.activeTab = \debates
    $scope.answer = (answer) ->
        | answer         => '已答'
        | otherwise      => '未答'
    $scope.mly = ({{mly}:entity}) ->
        return '' unless mly[0]
        party = LYService.resolveParty mly[0]
        avatar = CryptoJS.MD5 "MLY/#{mly[0]}" .toString!
        mly[0] + """<img class="avatar small #party" src="http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small" alt="#{mly[0]}">"""
    padLeft = (str, length) ->
        if str.length >= length
            return str
        padLeft '0'+str, length
    $scope.source = ({{{link}:source}:entity}) ->
        return '' unless link
        str = link[1].toString!.concat padLeft link[2],3 .concat padLeft link[3],2
        href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?'+str+';'.concat padLeft link[4],4 .concat ';'+padLeft link[5],4
        """<a href="#{href}" target="_blank">質詢公報</a>"""

    $scope.answers = ({{answers}:entity}) ->
        tmp = ''
        angular.forEach answers, !(value) ->
            if(!value.source.text.match /口頭答復/)
                link = value.source.link
                str = link[1].toString!.concat padLeft link[2],3 .concat padLeft link[3],2
                href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?'+str+';'.concat padLeft link[4],4 .concat ';'+padLeft link[5],4
                tmp += """<div><a href="#{href}" target="_blank">書面答復</a></div>"""
        if tmp === ''
            tmp += """口頭(見質詢公報)"""
        tmp
    $scope.pagingOptions = {
        pageSizes: [10 20 30]
        pageSize: 30
        currentPage: 1
    }
    $scope.$watch 'pagingOptions', !(newVal, oldVal)->
        if (newVal.pageSize !== oldVal.pageSize || newVal.currentPage !== oldVal.currentPage)
            $scope.getData newVal
    , true
    $scope.gridOptions = {+showFilter, +showColumnMenu, +showGroupPanel, +enableHighlighting, +enableRowSelection, +enablePaging, +showFooter} <<< do
        rowHeight: 80
        data: \debates
        pagingOptions: $scope.pagingOptions,
        i18n: \zh-tw
        columnDefs:
          * field: 'tts_id'
            displayName: \系統號
            width: 80
          * field: 'mly'
            displayName: \質詢人
            width: 130
            cellTemplate: """
            <div ng-bind-html-unsafe="mly(row)"></div>
            """
          * field: 'source'
            displayName: \質詢公報
            width: 80
            cellTemplate: """
            <div ng-bind-html-unsafe="source(row)"></div>
            """
          * field: 'answers'
            displayName: \答復公報
            width: 100
            cellTemplate: """
            <div ng-bind-html-unsafe="answers(row)"></div>
            """
          * field: 'summary'
            displayName: \案由
            visible: false
          * field: 'answered'
            displayName: \答復
            width: '50'
            cellTemplate: """
            <div ng-bind-html-unsafe="answer(row)"></div>
            """
          * field: 'date_asked'
            cellFilter: 'date: mediumDate'
            width: '100'
            displayName: \質詢日期
          * field: 'category'
            width: '*'
            displayName: \類別
            cellTemplate: """
            <div ng-repeat="c in row.getProperty(col.field) track by $id($index)"><span class="label">{{c}}</span></div>
            """
          * field: 'topic'
            displayName: \主題
            width: '*'
            cellTemplate: """
            <div ng-repeat="c in row.getProperty(col.field) track by $id($index)"><span class="label">{{c}}</span></div>
            """
          * field: 'keywords'
            displayName: \關鍵詞
            width: '*'
            cellTemplate: """
            <div ng-repeat="c in row.getProperty(col.field) track by $id($index)"><span class="label">{{c}}</span></div>
            """
          * field: 'answered_by'
            displayName: \答復人
            width: '80'
            cellTemplate: """
            <div ng-repeat="c in row.getProperty(col.field) track by $id($index)"><span >{{c}}</span></div>
            """
          * field: 'debate_type'
            displayName: \質詢性質
            width: '*'

    $scope.getData = ({currentPage, pageSize})->
        {paging, entries} <- $http.get 'http://api.ly.g0v.tw/v0/collections/debates' do
            params: do
                sk: (currentPage-1)*pageSize, l: pageSize
        .success
        angular.forEach entries, !(value, key)->
            value.date_asked = new Date value.date_asked
            value.source = JSON.parse value.source
        $scope.debates = entries
    $scope.getData $scope.pagingOptions
