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

angular.module 'app.controllers' <[app.controllers.calendar app.controllers.sittings app.controllers.search ng]>
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

.controller SearchFormCtrl: <[$scope $state]> ++ ($scope, $state) ->
  $scope.submitSearch = ->
    $state.transitionTo 'search.target', { keyword: $scope.searchKeyword}
    $scope.searchKeyword = ''


.controller LYBills: <[$scope $http $state $timeout LYService $sce $anchorScroll]> ++ ($scope, $http, $state, $timeout, LYService, $sce, $anchorScroll) ->
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
        [_, ..._items]? = text.match /第(.+)之(.+)條/ or text.match /第(.+)條(?:之(.+))?/
        return unless _items
        require! zhutil
        _items.filter -> it
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
          if parse-article-heading RegExp.lastMatch - /\s+$/
            left-item = \§ + that
            left-item-anchor = that
        newTextLines = entry[idx] || entry[base-index]
        newTextLines -= /^第(.*?)條(之.*?)?\s+/
        right-item = parse-article-heading RegExp.lastMatch - /\s+$/
        difflines = line-based-diff baseTextLines, newTextLines
        angular.forEach difflines, (value, key)->
          value.left = $sce.trustAsHtml value.left
          value.right = $sce.trustAsHtml value.right
        comment = $sce.trustAsHtml comment
        return {comment,difflines,left-item,left-item-anchor,right-item}
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
      total-entries = $scope.diff.map (.content.length) .reduce (+)
      $scope.showSidebar = total-entries > 3
      $scope.steps =
        * name: "proposal"
          description: "提案"
          status:
            step: "passed"
            state: "passed"
            icon: "check"
          date: "2013-10-1"
          detail:
            * name: "proposal"
              description: "經ＯＯ立委送至ＯＯ單位"
              status:
                step: "passed"
                state: "passed"
                icon: "check"
              date: "2013-10-1"
            * name: "schedule"
              description: "經程序委員會排入全院院會一讀議程"
              status:
                step: "passed"
                state: "passed"
                icon: "check"
              date: "2013-10-1"
        * name: "first-reading"
          description: "一讀"
          status:
            step: "issued"
            state: "not-yet"
            icon: ""
          date: "2013-10-2"
        * name: "committee"
          description: "委員會"
          status:
            step: "issued"
            state: "returned"
            icon: "exclamation"
          date: "2013-10-3"
        * name: "second-reading"
          description: "二讀"
          status:
            step: "scheduled"
            state: "not-yet"
            icon: ""
          date: "2013-10-4"
        * name: "third-reading"
          description: "三讀"
          status:
            step: "not-yet"
            state: "not-yet"
            icon: "check"
          date: ""
        * name: "announced"
          description: "頒佈"
          status:
            step: "not-yet"
            state: "not-yet"
            icon: "check"
          date: ""
        * name: "implemented"
          description: "生效"
          status:
            step: "not-yet"
            state: "hidden"
            icon: ""
          date: ""

      $timeout -> $anchorScroll!

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
