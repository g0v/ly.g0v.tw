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

class Steps

  (@bill, @lymodel, @scope) ->
    @proposal =
      sub: false
      desc:   "提案"
      icon:   ""
      status: "passed"
      date:   '?.?.?'
      detail: []
    @first_reading =
      sub: false
      desc:   "一讀"
      icon:   "comment"
      status: "scheduled"
      date:   '?.?.?'
      detail: []
    @committee =
      sub: false
      desc:   "付委"
      icon:   "chat"
      status: "not-yet"
      date:   '?.?.?'
      detail: []
    @second_reading =
      sub: false
      desc:   "二讀"
      icon:   "chat"
      status: "not-yet"
      date:   '?.?.?'
      detail: []
    @third_reading =
      sub: false
      desc:   "三讀"
      icon:   "chat"
      status: "not-yet"
      date:   '?.?.?'
      detail: []
    @announced =
      sub: false
      desc:   "頒佈"
      icon:   "unmute"
      status: "not-yet"
      date:   '?.?.?'
      detail: []
    @implemented =
      sub: false
      desc:   "生效"
      icon:   "legal"
      status: "not-yet"
      date:   '?.?.?'
      detail: []

  build: (cb) ->
    return @step if @step

    # proposal, first_reading, committee are crawled from motions.
    @build_from_motions!
    self <- @build_from_report!

    # proposal, first_reading, committee,
    # second_reading, third_reading, announced are crawled by ttsmotions.
    self <- self.build_from_ttsmotions!

    self.steps =
      * self.proposal
      * self.first_reading
      * self.committee
      * self.second_reading
      * self.third_reading
      * self.announced
      * self.implemented
    self.ensure_steps_status_order!
    self.ensure_only_one_scheduled_step!
    self.set_proposal_icon_if_bill_has_been_rejected!
    self.set_proposal_date_if_first_reading_has_date!
    cb self.steps

  build_from_motions: ->
    motions = @bill.motions.filter -> it.resolution != null
    for motion in motions
      desc = motion.resolution
      date = @pretty_date motion.dates.0.date
      switch
      # [accepted]
      # /照案通過/ -> not legislative
      # /提報院會/ -> not legislative
      # /列席報告/ -> scenario 1. duplicate with 中央政府總預算案
      #                        2. not legislative
      # /多數通過/ -> scenario 1. duplicate with 交 xxx 委員會審查
      #                        2. unkown committee
      #                           eg. 887G12800-813

      # [consultation]
      # /黨團協商/ -> scenario 1. deplicate with 逕付二讀
      #                        2. not legislative

      # [rejected] eg. 335L15406
      case desc.match /少數不通過|退回程序委員會/
        @proposal <<<
          status: \passed
          date:   date
          detail: [
            desc:  desc
            date:  date
          ]
        @first_reading <<<
          status: \scheduled
      # [committee] eg. 468L12892
      case desc.match /交([^，]+?)[兩三四五六七八]?委員會|中央政府總預算案/
        @proposal <<<
          status: \passed
        @first_reading <<<
          status: \passed
          date:   date
        @first_reading.detail.push do
          desc:  desc
          date:  date
        @committee <<<
          status: \scheduled
      # [extended] eg. 915G13287-1
      case desc.match /展延審查期限/
        @proposal <<<
          status: \passed
        @first_reading <<<
          status: \passed
        @committee <<<
          status: \scheduled
          date:  date
        @committee.detail.push do
          desc:  desc
          date:  date
      # [prioritized] eg. 1618L14627
      case desc.match /逕付(院會)?二讀/
        @proposal <<<
          status: \passed
        @first_reading <<<
          status: \passed
          date:   date
        @first_reading.detail.push do
          desc:  desc
          date:  date
        @committee <<<
          status: \passed
        @second_reading <<<
          status: \scheduled
      # [retrected] eg. 184L15146-1
      case desc.match /同意撤回/
        @proposal <<<
          status: \passed
        @first_reading <<<
          status: \passed
        @committee <<<
          status: \passed
        @second_reading <<<
          status: \passed
          date:   date
        @second_reading.detail.push do
          desc:  desc
          date:  date

  build_from_report: (cb) ->
    self = this
    func <- @report_of_bill @bill
    func.finally (report) ->
      cb self
    report <- func.success
    self.scope <<< {report}
    date = self.pretty_date report.motions.0.dates.0.date
    # eg. 335L15406
    self.committee <<<
      status: "passed"
      date:   date
    self.committee.detail.push do
      desc:  report.summary
      date:  date
    self.second_reading <<<
      if report.summary isnt /審查決議：「不予審議」/
        status: "scheduled"

  report_of_bill: (bill, cb) ->
    func = @lymodel.get "bills" params: do
      q: JSON.stringify do
        report_of: $contains: bill.bill_id
      fo: true
    cb func

  build_from_ttsmotions: (cb) ->
    return cb this if @bill.bill_ref == /-/ # original proposal
    self = this
    ttsmotions <- @get_ttsmotions!
    self.scope.ttsmotions = ttsmotions
    var prev_step
    for motion in ttsmotions
      motion.links = self.links_of_ttsmotion motion
      step = self.step_of_ttsmotion prev_step, motion
      self.update_step_by_ttsmotion prev_step, step, motion
      self.update_detail_by_ttsmotion step.detail, motion
      prev_step = step
    cb self

  get_ttsmotions: (cb) ->
    {entries: ttsmotions} <- @lymodel.get "ttsmotions" params: do
      s: {date: -1}
      q: JSON.stringify do
        bill_refs: $contains: @bill.bill_ref
    .success
    cb ttsmotions.reverse!

  # XXX this should be processed in api.ly
  links_of_ttsmotion: (ttsmotion) ->
    desc = new AugmentedString ttsmotion.resolution
    links = desc.scan /([\d-]+)\s\["(\w+)",(\d+),(\d+),(\d+),(\d+),(\d+)\]/
    links = links.filter (link) -> link.1 == \g
    links.map (link) ->
      text = 'p. ' + link.0
      vol  = new AugmentedString link.2 .rjust 3, '0'
      vol += new AugmentedString link.3 .rjust 3, '0'
      vol += new AugmentedString link.4 .rjust 2, '0'
      url = "http://lis.ly.gov.tw/lgcgi/lypdftxt?#vol;#{link.5};#{link.6}"
      {text, link: url}

  step_of_ttsmotion: (prev_step, ttsmotion) ->
    process = ttsmotion.progress
    desc    = ttsmotion.resolution
    switch
    case process == '復議(另定期處理)'
      switch
      # 1374L15430
      case prev_step == @first_reading => @first_reading
      # 1013L15476
      case prev_step == @committee     => @committee
      # 1559L14887
      case prev_step == @third_reading => @third_reading
    case process == /提案|退回程序/    => @proposal
    case process == /一讀/             => @first_reading
    case process == '委員會'           => @committee
    # 882L15375
    case process == /黨團協商/         => @second_reading
    case process == /二讀/
      if desc == /逕付(院會)?二讀/
        @first_reading
      else
        @second_reading
    # 471G14754
    case process == '撤回'             => @second_reading
    case process == /三讀/             => @third_reading
    # 882L13190
    case process == /覆議/             => @third_reading
    case process == /頒佈/             => @announced
    case process == /生效/             => @implemented
    case process == null
      switch
      # 1788L13286
      case desc == /另定期繼審審查/
        @committee
      case desc == /交黨團進行協商/
        @second_reading

  update_step_by_ttsmotion: (prev_step, step, ttsmotion) ->
    date = @date_of_ttsmotion ttsmotion
    process = ttsmotion.progress
    desc    = ttsmotion.resolution
    switch
    case process == '復議(另定期處理)'
      switch
      # 1374L15430
      case prev_step == @first_reading
        @first_reading <<<
          date:   date
      case prev_step == @committee
        @committee <<<
          date:   date
      case prev_step == @third_reading
        @third_reading <<<
          date:   date
    # eg. 1374L15430
    case desc == /交([^，]+?)[兩三四五六七八]?委員會|中央政府總預算案/
      @proposal <<<
        status: \passed
      @first_reading <<<
        status: \passed
        date:   date
      @committee <<<
        status: \scheduled
    case desc == /逕付(院會)?二讀/ => # do nothing
    # 1788L13286
    case desc == /另定期繼審審查/
      @proposal <<<
        status: \passed
      @first_reading <<<
        status: \passed
      @committee <<<
        status: \scheduled
        date:   date
    case process == /二讀/
      @committee <<<
        status: \passed
      @second_reading <<<
        status: \passed
        date:   date
      @third_reading <<<
        status: \scheduled
    case process == /覆議/
      @committee <<<
        status: \passed
      @second_reading <<<
        status: \passed
      if desc == /覆議案通過/
        @third_reading <<<
          status: \scheduled
          date:   date
        @announced <<<
          status: \not-yet
      else
        @third_reading <<<
          status: \passed
          date:   date
        @announced <<<
          status: \scheduled
    case process == /三讀/
      @committee <<<
        status: \passed
      @second_reading <<<
        status: \passed
      @third_reading <<<
        status: \passed
        date:   date
      @announced <<<
        status: \scheduled

  update_detail_by_ttsmotion: (detail, ttsmotion) ->
    date  = @date_of_ttsmotion ttsmotion
    desc  = @desc_of_ttsmotion ttsmotion
    links = ttsmotion.links
    steps = @substeps_of_detail detail
    step  = steps[date + desc]
    if step
      step <<< {links}
    else
      detail.push {date, desc, links}

  date_of_ttsmotion: (ttsmotion) ->
    moment ttsmotion.date .format 'YYYY.MM.DD'

  desc_of_ttsmotion: (ttsmotion) ->
    desc = ttsmotion.resolution
    desc = desc.replace /\(\S+\s+\S+\)/, ''
    desc = desc.replace /\s/g, ''
    desc

  substeps_of_detail: (detail) ->
    steps = {}
    for step in detail
      date = step.date
      desc = step.desc.replace /\決定：|\s/g, ''
      steps[date + desc] = step
    steps

  pretty_date: (date) ->
    date.replace /-/g, \.

  first_step_has_date: ->
    steps = @steps.filter -> it.date != '?.?.?'
    steps[0]

  step_with_elapsed: (step) ->
    if step
      parts = step.date.match /(\d+)\.(\d+)\.(\d+)/
      [year, month, day] = parts.slice 1
      date = new Date year, month, day
      now = new Date
      diff = new Date now.getTime! - date.getTime!
      diff-year  = @pretty_diff '年', diff.getUTCFullYear! - 1970
      diff-month = @pretty_diff '個月', diff.getUTCMonth!
      diff-day   = @pretty_diff '天', diff.getUTCDate! - 1
      {diff-desc: step.desc, diff-year, diff-month, diff-day}
    else
      {}

  pretty_diff: (unit, number) ->
    if number == 0
      ''
    else
      "#number #unit"

  ensure_steps_status_order: ->
    status = @steps[0].status
    statuses = [\passed, \scheduled, \not-yet]
    priorities = {passed: 0, scheduled: 1, 'not-yet': 2}
    for step in @steps
      priority = Math.max.apply null, [
        priorities[step.status],
        priorities[status]
      ]
      status = statuses[priority]
      step.status = status

  ensure_only_one_scheduled_step: ->
    prev = @steps[0]
    for step in @steps
      if step.status == \scheduled == prev.status
        prev.status = \passed
      prev = step

  # 1374L15430
  set_proposal_icon_if_bill_has_been_rejected: ->
    @proposal = @steps[0]
    if @proposal.date != '?.?.?'
      @proposal.icon = 'exclamation'

  # 1073L15722
  set_proposal_date_if_first_reading_has_date: ->
    [@proposal, @first_reading] = @steps
    if @proposal.date == '?.?.?'
      @proposal.date = @first_reading.date

class AugmentedString

  (@string) ->

  # a = "cruel world"
  # a.scan(/\w+/)        #=> ["cruel", "world"]
  # a.scan(/.../)        #=> ["cru", "el ", "wor"]
  # a.scan(/(...)/)      #=> [["cru"], ["el "], ["wor"]]
  # a.scan(/(..)(..)/)   #=> [["cr", "ue"], ["l ", "wo"]]
  scan: (pattern) ->
    ary = []
    string = @string
    while result = string.match pattern
      i = string.index-of result.0
      string = string.slice i + result.0.length
      item =
        if result.length == 1
          result.0
        else
          result.slice 1
      ary.push item
    ary

  # "hello".rjust(4)            #=> "hello"
  # "hello".rjust(20)           #=> "               hello"
  # "hello".rjust(20, '1234')   #=> "123412341234123hello"
  rjust: (width, padding = ' ') ->
    len = width - @string.length
    if len > 0
      times  = len / padding.length
      remain = len % padding.length
      string = new AugmentedString padding
      string = string.repeat times
      tail   = padding.slice 0, remain
      string = string.concat tail
      string.concat @string
    else
      @string

  # "Ho! ".repeat(3)  #=> "Ho! Ho! Ho! "
  # "Ho! ".repeat(0)  #=> ""
  repeat: (times) ->
    clone = ''
    for i to times - 1
      clone = clone.concat @string
    clone


angular.module 'app.controllers.bills' <[ly.diff ly.spy]>
.controller LYBillsIndex: <[$scope $state $timeout LYService LYModel $sce $anchorScroll TWLYService]> ++ ($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll, TWLYService) ->
  $scope.current-tab = '1'
  {entries: $scope.bill-stats} <- LYModel.get "analytics" params: do
    q: JSON.stringify do
      name: 'bill'
  .success
  $scope.$watch 'currentTab' ->
    [selected]? = [e for e in $scope.bill-stats when e.timeframe is it]
    selected.bills ?= [{bill_ref,count} for [bill_ref, count] in selected.content]
    for bill in selected.bills when !bill.sponsors => let bill
      bill-details <- LYModel.get "bills/#{bill.bill_ref}" .success
      bill <<< bill-details
      steps = new Steps bill, LYModel, {}
      steps-detail <- steps.build
      bill.steps = steps-detail
      step = steps.first_step_has_date!
      bill <<< steps.step_with_elapsed step
    $scope.current-bills = selected.bills

.controller LYBills: <[$scope $state $timeout LYService LYModel $sce $anchorScroll TWLYService]> ++ ($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll, TWLYService) ->
    $scope.diffs = []
    $scope.opts = {+show_date}
    $scope.spies = {}
    $scope.found = 'unknown'
    $scope.$watch '$state.params.billId' ->
      {bill-id} = $state.params
      req = LYModel.get "bills/#{bill-id}"
      req.error -> $scope.found = 'no'
      {committee}:bill <- req.success
      $scope.found = 'yes'
      $state.current.title = "國會大代誌 - #{bill.bill_ref || bill.bill_id} - #{bill.summary}"

      if bill.bill_ref #legislative
        if that isnt billId and that isnt /;/
          # make bill_ref the permalink
          return $state.transitionTo 'bills', { billId: bill.bill_ref }
        steps = new Steps bill, LYModel, $scope
        steps.build -> $scope.steps = it

        data <- LYModel.get "bills/#{billId}/data" .success
        $scope.diff = diffmeta data?content
        if $scope.diff?length
          total-entries = $scope.diff.map (.content.length) .reduce (+)
        $scope.showSidebar = total-entries > 3
        $timeout $anchorScroll

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
        angular.forEach $scope.steps, (step, i) ->
          if (index == i and
              step.detail.length >= 1)
            step.sub = !step.sub
          else
            step.sub = false
