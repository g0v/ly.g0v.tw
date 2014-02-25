parse-article-heading = (text) ->
  [_, ..._items]? = text.match /第(.+)之(.+)條/ or text.match /第(.+)條(?:之(.+))?/
  return text unless _items
  require! zhutil
  _items.filter -> it
  .map zhutil.parseZHNumber .join \-

not-an-article = /^(（\S+）\n|)第\S+(章|編|節)/

bill-amendment = (diff, idx, c, base-index) -> (entry) ->
  h = diff.header
  comment = if \string is typeof entry[c]
    entry[c]
  else
    entry[c][h[idx].replace /審查會通過條文/, \審查會]

  if comment
    comment.=replace /\n/g "<br><br>\n"
  baseTextLines = entry[base-index] or ''
  if baseTextLines
    baseTextLines -= /^第(.*?)(條(之.*?)?|章|篇|節)\s+/
    if parse-article-heading RegExp.lastMatch - /\s+$/
      original-article = that
  newTextLines = entry[idx] || entry[base-index] || ''
  newTextLines -= /^第(.*?)(條(之.*?)?|章|篇|節)\s+/
  article = parse-article-heading RegExp.lastMatch - /\s+$/
  if !original-article
    if newTextLines.match /^（\S+）\n第(.*?)條/ or newTextLines.match /^（\S+第(.*?)條，保留）/
      article = parse-article-heading RegExp.lastMatch - /\s+$/
    if newTextLines.match not-an-article
      article = newTextLines.replace /^（\S+）\n/, '' .split '　' .0
    else
      original-article = article || ''
  return {comment,article,original-article,content: newTextLines,base-content: baseTextLines}

diffmeta = (content) -> content?map (diff) ->
  if !diff.name
    diff.name = '併案審議'
  h = diff.header
  [base-index] = [i for n, i in h when n is /^現行/]
  [c] = [i for n, i in h when n is \說明]

  diff{header,content,name} <<< do
    versions: h.filter (it, i) -> it isnt \說明 and i isnt base-index
    base-index: base-index
    comment-index: c
    diffbase: h[base-index]
    diffnew: h.0
    amendment: diff.content.map bill-amendment diff, 0, c, base-index

function match-motions(substeps, ttsmotions)
  date = moment(ttsmotions.date) .format 'YYYY-MM-DD'
  for s in substeps
    if s.date is date and s.description is \決定： + ttsmotions.resolution.replace /\(\S+\s+\S+\)/, ''
      s.links = ttsmotions.links
      return
  substeps.push {date, description: ttsmotions.resolution, links: ttsmotions.links}

function build-steps(motions)
  steps =
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
      detail: []
    * name: "second-reading"
      sub: false
      description: "二讀"
      status:
        step: "not-yet not-implemented no-hover"
        state: "not-yet"
        icon: ""
      detail: []
    * name: "third-reading"
      sub: false
      description: "三讀"
      status:
        step: "not-yet not-implemented no-hover"
        state: "not-yet"
        icon: "check"
      date: ""
      detail: []
    * name: "announced"
      sub: false
      description: "頒佈"
      status:
        step: "not-yet not-implemented no-hover"
        state: "not-yet"
        icon: "check"
      date: ""
      detail: []
    * name: "implemented"
      sub: false
      description: "生效"
      status:
        step: "not-yet not-implemented no-hover"
        state: "hidden"
        icon: ""
      date: ""
      detail: []
  for motion, i in motions
    if i is 0 => steps.0.date = motion.dates.0.date
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
      steps[0].status
        ..state = "passed" if ..state is "not-yet"
        ..icon ||= "check"
      steps[1].status = detail.status
      steps[1].detail.push detail
      steps[2].status =
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
      steps[0].detail.push detail
      steps[0].status
        ..icon = \exclamation
        ..state = \returned
    | \committee
      detail =
        name: "scheduled"
        description: motion.resolution
        status:
          step: "passed"
          state: "passed"
          icon: "check"
        date: motion.dates[0].date
      steps[1].date = motion.dates[0].date
      steps[1].status = detail.status
      steps[1].detail.push detail
      steps[0].status
        ..state = "passed" if ..state is "not-yet"
        ..icon ||= "check"
      steps[0].detail.push detail
  steps

angular.module 'app.controllers.bills' <[ly.diff ly.spy ly.law-easy-read]>
.controller LYBills: <[$scope $state $timeout LYService LYModel $sce $anchorScroll TWLYService]> ++ ($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll, TWLYService) ->
    $scope.diffs = []
    $scope.opts = {+show_date}
    $scope.spies = {}
    $scope.$watch '$state.params.billId' ->
      {billId} = $state.params
      {committee}:bill <- LYModel.get "bills/#{billId}" .success
      $state.current.title = "國會大代誌 - #{bill.bill_ref || bill.bill_id} - #{bill.summary}"

      if bill.bill_ref #legislative
        if that isnt billId and that isnt /;/
          # make bill_ref the permalink
          return $state.transitionTo 'bills', { billId: bill.bill_ref }
        $scope.steps = build-steps bill.motions
        if bill.bill_ref isnt /-/ # original proposal
          require! sprintf
          {entries: $scope.ttsmotions} <- LYModel.get "ttsmotions" params: do
            s: {date: -1}
            q: JSON.stringify do
              bill_refs: $contains: bill.bill_ref
          .success
          for m, i in $scope.ttsmotions
            # XXX this should be processed in api.ly
            m.resolution -= /\(p\.(.*)\)/
            a = RegExp.$1.split /(?:[\s,;]*)?(.*?)\s*(\[.*?\])/
            res = []
            do
              [_, text, link]:x = a.slice 0, 3
              if x.length is 3
                link = JSON.parse link
                # linkify type 'g'
                #// /lgcgi/lypdftxt\?(\d\d\d?)(\d\d\d)(\d\d);(\d+);(\d+) //
                if link.0 is \g
                  vol = sprintf "%03d%03d%02d", ...link[1 to 3]
                  link = "http://lis.ly.gov.tw/lgcgi/lypdftxt?#vol;#{link.4};#{link.5}"
                res.push {text, link}
              else
                break
            while a.splice 0, 3
            m.links = res
            switch m.progress
            case '提案', '退回程序' => match-motions $scope.steps[0].detail, m
            case '一讀' => match-motions $scope.steps[1].detail, m
            case '委員會' => match-motions $scope.steps[2].detail, m
            case '二讀' => match-motions $scope.steps[3].detail, m
            case '三讀' => match-motions $scope.steps[4].detail, m
            case '頒佈' => match-motions $scope.steps[5].detail, m
            case '生效' => match-motions $scope.steps[6].detail, m

          report <- LYModel.get "bills" params: do
            q: JSON.stringify do
              report_of: $contains: bill.bill_id
            fo: true
          .success
          $scope <<< {report}
          $scope.steps.3.date = report.motions.0.dates.0.date
          $scope.steps.3.status
            ..step = 'scheduled'
          detail = do
            name: "committee"
            description: report.summary
            status: do
              if report.summary is /審查決議：「不予審議」/
                step: "red"
                state: "red"
                icon: "exclamation"
              else
                step: "passed"
                state: "passed"
                icon: "check"
          $scope.steps.2.status = detail.status
          $scope.steps.2.detail.push detail

        data <- LYModel.get "bills/#{billId}/data" .success
        $scope.diff = diffmeta data?content
        if $scope.diff?length
          total-entries = $scope.diff.map (.content.length) .reduce (+)
        $scope.showSidebar = total-entries > 3

      committee ?.= map -> { abbr: it, name: committees[it] }
      $scope <<< bill{summary,abstract,bill_id,bill_ref,doc,sponsors,cosponsors} <<< {committee} <<<
        setDiff: (diff, version) ->
            [idx] = [i for n, i in diff.header when n is version]
            base-index = diff.base-index
            c = diff.comment-index
            amendment = diff.content.map bill-amendment diff, idx, c, base-index
            diff <<< diffnew: version
      $scope.$watch '$state.params.otherBills' ->
        other-bills = it?split \,
        return unless other-bills?length
        $scope.bill_refs = [$scope.bill_ref] ++ other-bills
        for billId in other-bills
          bill <- LYModel.get "bills/#{billId}" .success
          data <- LYModel.get "bills/#{billId}/data" .success
          $scope.to-compare ?= {}
          $scope.to-compare[billId] = bill <<< diff: diffmeta data?content
      $scope.$watch 'toCompare' ->
        return unless it
        $scope.diff-matrix = matrix = {}
        expand = (bill_ref, content) ->
          for d in content
            matrix[d.name] ?= {}
            for entry in d.amendment
              x = matrix[d.name][entry.article || entry.original-article] ?= {}
              x[bill_ref] = entry
        expand $scope.bill_ref, $scope.diff
        for k, val of it => expand k, val.diff
        console.log matrix

      $scope.showSub = (index) ->
        angular.forEach $scope.steps, (v, i) ->
          if index == i
            v.sub = !v.sub
          else v.sub = false
      $timeout -> $anchorScroll!
