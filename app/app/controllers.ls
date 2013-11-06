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

line-based-diff = (text1, text2) ->
  # https://code.google.com/p/google-diff-match-patch/wiki/API
  dmp = new diff_match_patch
  dmp.Diff_Timeout = 1  # sec
  dmp.Diff_EditCost = 4
  ds = dmp.diff_main text1, text2
  dmp.diff_cleanupSemantic ds

  make-line-object = -> {left: '', right: ''}

  is-left = (target) -> target isnt \right
  is-right = (target) -> target isnt \left

  difflines = [ make-line-object! ]
  last_left = last_right = 0
  for [target, text] in ds
    target = switch target
             | 0  => \both
             | 1  => \right
             | -1 => \left

    lines = text / '\n'
    for line, i in lines
      if line != ''
        line = "<em>#line</em>" if target isnt \both
        if is-left target
          difflines[last_left].left += line
        if is-right target
          difflines[last_right].right += line

      if i != lines.length - 1
        difflines.push make-line-object!
        if is-left target
          last_left = difflines.length - 1
        if is-right target
          last_right = difflines.length - 1

  for line in difflines
    if line.left == '' and line.right != ''
      line.state = \insert
    else if line.left != '' and line.right == ''
      line.state = \delete
    else if line.left != '' and line.right != ''
      line.state = if line.left == line.right then \equal else \replace
    else
      line.state = \empty

  return difflines

angular.module 'app.controllers' <[app.controllers.calendar ng]>
.run <[$rootScope]> ++ ($rootScope) ->
  $rootScope.committees = committees
.controller AppCtrl: <[$scope $location $rootScope $sce]> ++ (s, $location, $rootScope, $sce) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

.filter \committee, <[$sce]> ++ ($sce) -> (value) -> $sce.trustAsHtml renderCommittee value

.controller LYBills: <[$scope $http $state LYService $sce]> ++ ($scope, $http, $state, LYService, $sce) ->
    $scope.diffs = []
    $scope.diffstate = (left_right, state) ->
      | left_right is 'left' and state isnt 'equal' => 'red'
      | state === 'replace' || state === 'empty' || state === 'insert' || state === 'delete' => 'green'
      | otherwise => ''
    $scope.difftxt = (left_right, state) ->
      | left_right is 'left' and state isnt 'equal' => '現行'
      | state === 'replace' || state === 'empty' => '修正'
      | state === 'delete' => '刪除'
      | state === 'insert' => '新增'
      | otherwise => '相同'
    $scope.$watch '$state.params.billId' ->
      {billId} = $state.params
      {committee}:bill <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/bills/#{billId}"
      .success
      if bill.bill_ref and bill.bill_ref isnt billId
        # make bill_ref the permalink
        return $state.transitionTo 'bills', { billId: bill.bill_ref }
      $state.current.title = "ly.g0v.tw - #{bill.bill_ref || bill.bill_id} - #{bill.summary}"
      data <- $http.get "http://api-beta.ly.g0v.tw/v0/collections/bills/#{billId}/data"
      .success

      if committee
          committee = committee.map -> { abbr: it, name: committees[it] }

      parse-article-heading = (text) ->
        [_, ..._items]? = text.match /第(.+)條(?:之(.+))?/
        return unless _items
        require! zhutil
        \§ + _items.filter -> it
        .map zhutil.parseZHNumber .join \-
      diffentry = (diff, idx, c, base-index) -> (entry) ->
        h = diff.header
        comment = if \string is typeof entry[c]
          entry[c]
        else
          entry[c][h[idx].replace /審查會通過條文/, \審查會]

        if comment
          comment.=replace /\n/g "<br><br>\n"
        baseTextLines = entry[base-index] or ''
        if baseTextLines
          baseTextLines -= /^第(.*?)條(之.*?)?\s+/
          left-item = parse-article-heading RegExp.lastMatch - /\s+$/
        newTextLines = entry[idx] || entry[base-index]
        newTextLines -= /^第(.*?)條(之.*?)?\s+/
        right-item = parse-article-heading RegExp.lastMatch - /\s+$/
        difflines = line-based-diff baseTextLines, newTextLines
        angular.forEach difflines, (value, key)->
          value.left = $sce.trustAsHtml value.left
          value.right = $sce.trustAsHtml value.right
        comment = $sce.trustAsHtml comment
        return {comment,difflines,left-item,right-item}
      $scope <<< bill{summary,abstract,bill_ref,doc} <<< do
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
            [idx] = [i for n, i in diff.header when n is version]
            base-index = diff.base-index
            c = diff.comment-index
            diff <<< do
                diffnew: version
                diffcontent: diff.content.map diffentry diff, idx, c, base-index
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
                diffcontent: diff.content.map diffentry diff, 0, c, base-index

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

.controller LYSittings: <[$rootScope $scope $http $state LYService LYModel]> ++ ($rootScope, $scope, $http, $state, LYService, LYModel) ->
  $rootScope.activeTab = \sittings
  $scope.committees = committees
  $scope <<< lists:{}
  if window.YT
    $scope.youtube-ready = true
  else
    $scope.$on \youtube-ready ->
      $scope.youtube-ready = true

  $scope.setContext = (ctx) ->
    $scope.context = ctx
    $state.params.sitting = null

  $scope.$watch '$state.params.sitting' ->
    if $state.params.sitting
      console.log 'specified sitting, get context from id of sitting'
      $scope.context = that - /[\d-]/g
      loadSitting that
    else
      console.log 'no specified sitting, use YS as default context if necessary'
      $scope.context ||= 'YS'

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
    {entries} <- LYModel.get 'sittings' do
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
    state = if $state.current.name is /^sittings.detail/ => $state.current.name else 'sittings.detail'
    $state.transitionTo state, { sitting: id }
    $scope.loadingSitting = true
    result <- LYModel.get "sittings/#{id}"
    .success
    $scope.loadingSitting = false
    $scope <<< result
    $scope.data = []
    $scope.data[\announcement] = getMotionsInType result.motions, \announcement
    $scope.data[\discussion] = getMotionsInType result.motions, \discussion
    $scope.data[\exmotion] = getMotionsInType result.motions, \exmotion
    $scope.setType \announcement

    # XXX: this GET request should be removed if we have vidoes counts in previous request
    videos <- LYModel.get "sittings/#{id}/videos"
    .success
    $scope.videos = videos

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
    if $scope.player.getPlayerState! is -1 # unstarted
      $scope.player.playVideo!
      $scope.player.nextStart = seconds
    else
      $scope.player.seekTo seconds
  var hash-watch
  $scope.$watch '$state.current.name + $state.params.sitting' ->
    if $state.current.name is \sittings.detail.video
      $scope.video = true
      return if $scope.loaded is $state.params.sitting
      $scope.loaded = $state.params.sitting
      var play-time
      hash-watch := $scope.$watch '$location.hash()' ->
        return unless it
        play-time := moment it + '+08:00'
      videos <- LYModel.get "sittings/#{$state.params.sitting}/videos"
      .success
      whole = [v <<< {first_frame: moment v.first_frame_timestamp ? v.time} for v in videos when v.firm is \whole]
      if play-time
        for v in whole
          if v.first_frame <= play-time <= v.first_frame + v.length * 1000
            $scope.current-video = v
      else
        $scope.current-video = whole.0

      clips = for v in videos when v.firm isnt \whole
        { v.time, mly: v.speaker - /\s*委員/, v.length, v.thumb }

      #YOUTUBE_APIKEY = 'AIzaSyDT6AVKwNjyWRWtVAdn86Q9I7HXJHG11iI'
      #details <- $http.get "https://www.googleapis.com/youtube/v3/videos?id=#{$scope.current-video.youtube_id}&key=#{YOUTUBE_APIKEY}&part=snippet,contentDetails,statistics,status" .success
      #if details.items?0
      #  [_, h, m, s] = that.contentDetails.duration.match /^PT(\d+H)?(\d+M)?(\d+S)/
      #  duration = (parseInt(h) * 60 + parseInt m) * 60 + parseInt s
      done = false
      onPlayerReady = (event) ->
        $scope.player = event.target
        if play-time
          first-timestamp = $scope.current-video.first_frame
          $scope.player.nextStart = (play-time - first-timestamp) / 1000
          $scope.player.playVideo!
          play-time := null
          $ '#player' .get 0 .scrollIntoView!

      timer-id = null
      onPlayerStateChange = (event) ->
        # set waveform location indicator
        if event.data is YT.PlayerState.PLAYING and not done
          if $scope.player.nextStart
            setTimeout (-> $scope.player.seekTo that), 50ms
            $scope.player.nextStart = null
          if timer-id => clearInterval timer-id
          timer = {}
            ..sec = $scope.player.getCurrentTime!
            ..start = new Date!getTime! / 1000
            ..rate = $scope.player.getPlaybackRate!
            ..now = 0
          handler = ->
            timer.now = new Date!getTime! / 1000
            # XXX: record actual current waveform
            $scope.$apply -> $scope.waveforms.0.current = timer.sec + (timer.now - timer.start) * timer.rate
          timer-id := setInterval ->
            handler!
          , 10000
          handler!
        else
          if timer-id => clearInterval timer-id
          timer-id := null
        return

      if $scope.player
        $scope.player.loadVideoById do
          videoId: $scope.current-video.youtube_id
      else
        player-init = ->
          new YT.Player 'player' do
            height: '390'
            width: '640'
            videoId: $scope.current-video.youtube_id
            events:
              onReady: onPlayerReady
              onStateChange: onPlayerStateChange
        if $scope.youtube-ready
          player-init!
        else
          $scope.$on \youtube-ready ->
            player-init!

      $scope.waveforms = []
      $scope.current-id = $scope.current-video.youtube_id
      mkwave = (wave, speakers, first_frame, time, index) ->
        # XXX: empty special case when wave is not ready
        waveclips = []
        for d,i in wave => wave[i] = d/255
        $scope.waveforms[index] = do
          id: whole[index].youtube_id
          wave: wave,
          speakers: speakers,
          current: 0,
          start: first_frame
          time: time,
          cb: ->
            if $scope.current-id isnt @id =>
              $scope.player.loadVideoById @id
              play-time := null
              $scope.current-id = @id
              [$scope.current-video] = [v for v in whole when v.youtube_id is @id]
            $scope.player?nextStart = it
            $scope.playFrom it
        #dowave wave, clips, (-> $scope.playFrom it), first-timestamp
      whole.forEach !(waveform, index) ->
        # XXX whole clips for committee can be just AM/PM of the same day
        start = waveform.first_frame
        end = start + waveform.length * 1000
        speakers = clips.filter -> start < +moment(it.time) <= end
        for clip in speakers
          clip.offset = moment(clip.time) - start
        wave <- $http.get "http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/#{waveform.wmvid}.json"
        .error -> mkwave [], speakers, waveform.first_frame, waveform.time, index
        .success
        mkwave wave, speakers, waveform.first_frame, waveform.time, index
    else
      # disabled
      $scope.loaded = null
      $scope.video = null
      hash-watch?!

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
