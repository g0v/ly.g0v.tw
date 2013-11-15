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

angular.module 'app.controllers.bills' []
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
        if !left-item
          left-item = \§ + right-item
          left-item-anchor = right-item 
        difflines = line-based-diff baseTextLines, newTextLines
        angular.forEach difflines, (value, key)->
          value.left = $sce.trustAsHtml value.left
          value.right = $sce.trustAsHtml value.right
        comment = $sce.trustAsHtml comment
        return {comment,difflines,left-item,left-item-anchor,right-item}
      $scope.steps =
        * name: "proposal"
          sub: false
          description: "提案"
          status:
            step: "passed"
            state: "not-yet"
            icon: ""
          detail: []
        * name: "first-reading"
          sub: false
          description: "一讀"
          status:
            step: "not-yet"
            state: "not-yet"
            icon: ""
          detail: []
        * name: "committee"
          sub: false
          description: "委員會"
          status:
            step: "not-yet"
            state: "not-yet"
            icon: ""
        * name: "second-reading"
          sub: false
          description: "二讀"
          status:
            step: "not-yet not-implemented no-hover"
            state: "not-yet"
            icon: ""
        * name: "third-reading"
          sub: false
          description: "三讀"
          status:
            step: "not-yet not-implemented no-hover"
            state: "not-yet"
            icon: "check"
          date: ""
        * name: "announced"
          sub: false
          description: "頒佈"
          status:
            step: "not-yet not-implemented no-hover"
            state: "not-yet"
            icon: "check"
          date: ""
        * name: "implemented"
          sub: false
          description: "生效"
          status:
            step: "not-yet not-implemented no-hover"
            state: "hidden"
            icon: ""
          date: ""
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
        motions: bill.motions?map (motion, i) ->
          if i is 0
            $scope.steps[0].date = motion.dates[0].date
            if motion.status is \rejected
              $scope.steps[0].status
                ..icon = \exclamation
                ..state = \returned
          match motion.status
          | \prioritized # example 1618L14627
            detail =
              name: "proposal"
              description: motion.resolution
              status:
                step: "passed"
                state: "passed"
                icon: "star"
              date: motion.dates[0].date
            $scope.steps[1].status = detail.status
            $scope.steps[1].detail.push detail
            $scope.steps[2].status =
              icon: "star"
              state: "passed"
          | \rejected # example: 335L15406
            detail =
              name: "proposal"
              description: motion.resolution
              status:
                step: "returned"
                state: "returned"
                icon: "exclamation"
              date: motion.dates[0].date
            $scope.steps[0].detail.push detail
          | \committee
            detail =
              name: "scheduled"
              description: motion.resolution
              status:
                step: "passed"
                state: "passed"
                icon: "check"
              date: motion.dates[0].date
            $scope.steps[1].date = motion.dates[0].date
            $scope.steps[1].status = detail.status
            $scope.steps[1].detail.push detail
            $scope.steps[0].status.state = "passed" if $scope.steps[0].status.state is "not-yet"
            $scope.steps[0].status.icon ||= "check"
            $scope.steps[0].detail.push detail
      total-entries = $scope.diff.map (.content.length) .reduce (+)
      $scope.showSidebar = total-entries > 3
      $scope.showSub = (index) ->
        angular.forEach $scope.steps, (v, i) ->
          if index == i
            v.sub = !v.sub
          else v.sub = false
      $timeout -> $anchorScroll!
