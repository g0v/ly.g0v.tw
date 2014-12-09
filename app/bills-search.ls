angular.module 'app.controllers.bills-search' <[ngClipboard]>
.controller \LYBillsSearch,
<[$rootScope   $scope  LYModel  $stateParams   $location]> ++ (
  $root-scope, $scope, LYModel, $state-params, $location
) ->
  $scope.today = moment!.start-of 'day' .format 'YYYY MM/DD'
  get_latest_sitting = (cb) ->
    {entries} <- LYModel.get 'sittings' do
      params: l: 1
    .success
    cb entries[0]
  get_session_sittings = (ad, session, cb) ->
    {entries} <- LYModel.get 'sittings' do
      params:
        q: ad: ad, session: session
        l: 500
    .success
    cb entries
  get_session_periods_before_by = (ad, session, cb) ->
    periods = []
    funcs = [session to 1 by -1].map (session) ->
      (done) ->
        period <- get_session_period ad, session
        periods.push period
        done!
    err, res <- async.series funcs
    cb periods
  get_session_period = (ad, session, cb) ->
    {entries} <- LYModel.get 'calendar' do
      params:
        s: JSON.stringify date: 1
        q: ad: ad, session: session
        l: 1
    .success
    oldest_date = entries[0]
    {entries} <- LYModel.get 'calendar' do
      params:
        s: JSON.stringify date: -1
        q: ad: ad, session: session
        l: 1
    .success
    latest_date = entries[0]
    period = [oldest_date, latest_date].map (entry) ->
      dates_of_calendar_entry entry
    period = {period, ad, session}
    cb period
  dates_of_calendar_entry = (entry) ->
    moment entry.date, 'YYYY-MM-DD'

  select_sittings_by_session = (sittings, session) ->
    sittings.filter (sitting) ->
      sitting.session == session

  select_oldest_and_latest_dates = (dates) ->
    dates = dates.map (date) -> date.unix!
    oldest_date = _.min dates
    latest_date = _.max dates
    [oldest_date, latest_date].map -> moment.unix it
  dates_of_sitting = (sitting) ->
    sitting.dates.map (date) ->
      moment date.date, 'YYYY-MM-DD'

  build_session_from_period = (period) ->
    ad = period.ad
    session = period.session
    name = "#{period.ad} 屆 #{period.session} 會期"
    period = format_period period.period
    {name, period, ad, session}
  format_period = (period) ->
    [oldest_date, latest_date] = period
    if oldest_date.year! == latest_date.year!
      year = oldest_date.year!
      oldest_date = oldest_date.format 'MM/DD'
      latest_date = latest_date.format 'MM/DD'
      "#year #{oldest_date} - #{latest_date}"
    else
      oldest_date = oldest_date.format 'YYYY/MM/DD'
      latest_date = latest_date.format 'YYYY/MM/DD'
      "#{oldest_date} - #{latest_date}"

  sort_sittings_by_date_ascending = (sittings) ->
    sittings.sort (sitting1, sitting2) ->
      [oldest_date, latest_date1] = period_of_sitting sitting1
      [oldest_date, latest_date2] = period_of_sitting sitting2
      latest_date1.diff latest_date2, 'days'
  latest_years_of_sittings = (sittings, committee) ->
    latest_dates_attr_of_sittings sittings, committee, (date) ->
      return true
    , (date) ->
      date.year!
  latest_months_of_sittings = (sittings, committee, year) ->
    latest_dates_attr_of_sittings sittings, committee, (date) ->
      date.year! == year
    , (date) ->
      date.month!
  latest_days_of_sittings = (sittings, committee, year, month) ->
    latest_dates_attr_of_sittings sittings, committee, (date) ->
      ( date.year!  == year &&
        date.month! == month)
    , (date) ->
      date.date!
  latest_dates_attr_of_sittings = (sittings, committee, filter, select_attr) ->
    sittings = select_sittings_by_committee sittings, committee
    dates = latest_dates_of_sittings sittings
    dates = dates.filter (date) ->
      filter date
    attrs = dates.map (date) ->
      select_attr date
    uniq_attrs attrs
  latest_sittings_of_sittings = (sittings, committee, year, month, day) ->
    sittings = select_sittings_by_committee sittings, committee
    dates = latest_dates_of_sittings sittings
    _.zip(sittings, dates).filter (sitting_with_date) ->
      [sitting, date] = sitting_with_date
      ( date.year! == year &&
        date.month! == month &&
        date.date! == day)
    .map (sitting_with_date) ->
      [sitting, date] = sitting_with_date
      {sitting.extra, sitting.sitting, sitting.committee, sitting.id}
  select_sittings_by_committee = (sittings, committee) ->
    sittings.filter (sitting) ->
      if committee
        committee == committee_of_sitting sitting
      else # no limit to committee
        true
  latest_dates_of_sittings = (sittings) ->
    sittings.map (sitting) ->
      [oldest_date, latest_date] = period_of_sitting sitting
      latest_date
  period_of_sitting = (sitting) ->
    dates = dates_of_sitting sitting
    select_oldest_and_latest_dates dates
  uniq_attrs = (attrs) ->
    _.uniq attrs

  format_sittings_summary = (sittings, committees_map) ->
    sittings.map (sitting) ->
      sitting.summary = format_sitting_summary sitting, committees_map
      sitting
  format_sitting_summary = (sitting, committees_map) ->
    {extra, sitting, committee} = sitting
    union = format_sitting_union committee, committees_map
    if extra
      "第 #extra 次臨時會 - 第 #sitting 次#{union}會議"
    else
      "第 #sitting 次#{union}會議"
  format_sitting_union = (committee, committees_map) ->
    if committee && committee.length > 1
      committee = committee.map (type) ->
        committees_map[type]
      "#{committee.join '，'}委員會聯席"
    else
      ''
  find_suitable_committee = (sittings, committees, danger_type) ->
    selectable_committees = selectable_committees_of_sittings sittings
    types = [danger_type]
    types ++= committees.map (committee) -> committee.type
    _.find types, (type) ->
      selectable_committees[type]
  selectable_committees_of_sittings = (sittings) ->
    selectable_committees = {}
    sittings.map (sitting) ->
      committee = committee_of_sitting sitting
      selectable_committees[committee] = true
    selectable_committees
  committee_of_sitting = (sitting) ->
    if sitting.committee
      sitting.committee[0]
    else
      'YS'
  select_possible_options = (options, danger_options) ->
    safe_option = options[*-1]
    danger_option = _.find danger_options, (danger_option) ->
      is_option_possible options, danger_option
    danger_option || safe_option
  select_possible_option = (options, danger_option) ->
    safe_option = options[*-1]
    if is_option_possible options, danger_option
      danger_option
    else
      safe_option
  is_option_possible = (options, danger_option) ->
    _.contains options, danger_option

  find_suitable_session = (sessions, safe_session, danger_session) ->
    danger_session = _.find sessions, (session) ->
      (session.ad == danger_session.ad || !danger_session.ad) &&
      (session.session == danger_session.session || !danger_session.session)
    danger_session || safe_session
  find_suitable_sitting = (sittings, danger_sittings) ->
    safe_sitting = sittings[0]
    danger_sittings = danger_sittings.map (danger_sitting) ->
      suitable_sitting_in sittings, danger_sitting
    danger_sitting = _.find danger_sittings, (sitting) ->
      sitting
    danger_sitting || safe_sitting
  suitable_sitting_in = (sittings, danger_sitting) ->
    _.find sittings, (sitting) ->
      danger_sitting &&
      sitting.extra == danger_sitting.extra &&
      sitting.sitting == danger_sitting.sitting
  find_suitable_motion_type = (motion_types, danger_types) ->
    types = {}
    motion_types.map (type) ->
      types[type] = true
    safe_type = motion_types[0]
    danger_type = _.find danger_types, (danger_type) ->
      types[danger_type]
    danger_type || safe_type
  parse_month = (month) ->
    parse_param(month) - 1
  parse_sitting = (extra, sitting) ->
    extra = parse_param extra
    sitting = parse_param sitting
    {extra, sitting}
  parse_session = (ad, session) ->
    ad = parse_param ad
    session = parse_param session
    {ad, session}
  parse_param = (param) ->
    if param == /^[1-9]\d*$/
      parse-int param
    else
      null

  find_sitting_by_id = (sittings, sitting_id) ->
    _.find sittings, (sitting) ->
      sitting.id == sitting_id
  add_type_to_motions = (motions) ->
    motions.map (motion) ->
      motion.type = parse_motion_type motion
  add_is_new_bill_to_motions = (motions, sitting) ->
    motions.map (motion) ->
      motion.is_new_bill = motion.sitting_introduced == sitting.id
  add_status_to_motions = (motions) ->
    funcs = motions.map (motion) ->
      (done) ->
        bill <- LYModel.get("bills/#{motion.bill_id}").success
        steps <- new Steps(bill, LYModel, motions).build
        motion.status = status_of_bill steps
        done!
    err, res <- async.series funcs
  parse_motion_type = (motion) ->
    switch
    case motion.bill_ref == /^\d+[LG]\d+$/
      switch
      case motion.summary == /預算/
        \預算
      case motion.summary == /請審議/
        \修法
      else
        \其他
    case motion.bill_ref == /^\d+[LG]\d+-\d+$/
      switch
      case motion.summary == /預算書案/
        \預算
      case motion.summary == /^報告審查/
        \修法
      else
        \查照
    case motion.bill_ref == /;/
      \修法
    else
      \未知
  status_of_bill = (steps) ->
    step = find_last_passed_step steps
    moment.locale 'zh-tw'
    desc = step.desc
    if step.date == \?.?.?
      "已#{desc}"
    else
      time = moment(step.date, 'YYYY.MM.DD').from-now!
      "已#{desc}，#time"
  find_last_passed_step = (steps) ->
    _.find-last steps, (step) ->
      step.status == \passed
  select_motions_by_type = (motions, motion_type) ->
    motions.filter (motion) ->
      motion_type == \全部 || motion.type == motion_type

  latest_sitting <- get_latest_sitting!
  latest_session_period <- get_session_period(
    latest_sitting.ad, latest_sitting.session)
  other_sessions_period <- get_session_periods_before_by(
    latest_sitting.ad, latest_sitting.session - 1)
  $scope.latest_session = build_session_from_period latest_session_period
  $scope.other_sessions = other_sessions_period.map (period) ->
    build_session_from_period period

  escape_param = (param) ->
    if $state-params[param]
      that.replace /[^a-z0-9]/gi, ''
    else
      null

  var sittings

  $scope.recursive_run_funcs = {}
  $scope.select_sitting_year = (selected_sitting_year) ->
    if ($scope.recursive_run_funcs[\$scope.select_sitting_year] ||
        $scope.recursive_run_funcs[\$scope.select_sitting_month] ||
        $scope.recursive_run_funcs[\$scope.select_sitting_day])
      $scope.recursive_run_funcs = {}
      return
    $scope.recursive_run_funcs[\$scope.select_sitting_year] = true
    $scope.sitting_year = selected_sitting_year
    $state-params.sitting_year = $scope.sitting_year
    months = latest_months_of_sittings(
      sittings, $scope.committee, $scope.sitting_year)
    month = select_possible_options(months,
      [parse_month(escape_param(\month)), $scope.sitting_month])
    $scope.sittings_month = months
    $scope.select_sitting_month month
  $scope.select_sitting_month = ($scope.sitting_month) ->
    $state-params.sitting_month = $scope.sitting_month
    $scope.recursive_run_funcs[\$scope.select_sitting_month] = true
    days = latest_days_of_sittings(
      sittings, $scope.committee, $scope.sitting_year, $scope.sitting_month)
    day = select_possible_options(days,
      [parse_param(escape_param(\day)), $scope.sitting_day])
    $scope.sittings_day = days
    $scope.select_sitting_day day
  $scope.select_sitting_day = ($scope.sitting_day) ->
    $state-params.sitting_day = $scope.sitting_day
    $scope.recursive_run_funcs[\$scope.select_sitting_day] = true
    sittings_sittings = latest_sittings_of_sittings(
      sittings, $scope.committee, $scope.sitting_year, $scope.sitting_month,
      $scope.sitting_day)
    sittings_sitting = format_sittings_summary sittings_sittings, $scope.committees_map
    param_sitting = parse_sitting escape_param(\extra), escape_param(\sitting)
    sitting = find_suitable_sitting(sittings_sittings,
      [param_sitting, $scope.sitting_sitting])
    committee = committee_of_sitting sitting
    $scope.sittings_sitting = sittings_sitting
    $scope.select_sitting_sitting sitting
    $scope.select_committee committee
  $scope.select_sitting_sitting = ($scope.sitting_sitting) ->
    $state-params.extra = $scope.sitting_sitting.extra
    $state-params.sitting = $scope.sitting_sitting.sitting
    summary = format_sitting_summary $scope.sitting_sitting, $scope.committees_map
    sitting = find_sitting_by_id sittings, $scope.sitting_sitting.id
    motions = sitting.motions
    motion_type = find_suitable_motion_type($scope.motion_types,
      [escape_param(\motion_type), $scope.motion_type])
    add_type_to_motions motions
    add_is_new_bill_to_motions motions, sitting
    $scope.sitting_sitting_summary = summary
    $scope.motions = motions
    $scope.select_motion_type motion_type
    add_status_to_motions motions
  $scope.select_committee = (selected_committee) ->
    committees = selectable_committees_of_sittings sittings
    if !committees[selected_committee]
      return
    $scope.committee = selected_committee
    $state-params.committee = $scope.committee
    if $scope.recursive_run_funcs[\$scope.select_committee]
      $scope.recursive_run_funcs = {}
      return
    $scope.recursive_run_funcs[\$scope.select_committee] = true
    years = latest_years_of_sittings sittings, $scope.committee
    year = select_possible_options(years,
      [parse_param(escape_param(\year)), $scope.sitting_year])
    $scope.sittings_year = years
    $scope.sitting_year = year
    $scope.select_sitting_year year
  $scope.select_motion_type = ($scope.motion_type) ->
    $state-params.motion_type = $scope.motion_type
    motions = select_motions_by_type $scope.motions, $scope.motion_type
    $scope.selected_motions = motions
  $scope.select_session = ($scope.session) ->
    $state-params.ad = $scope.session.ad
    $state-params.session = $scope.session.session
    entries <- get_session_sittings $scope.session.ad, $scope.session.session
    sittings := entries
    sort_sittings_by_date_ascending sittings
    committee = find_suitable_committee(sittings,
      $scope.committees, escape_param(\committee))
    $scope.select_committee committee
  sessions = [$scope.latest_session] ++ $scope.other_sessions
  params_session = parse_session escape_param(\ad), escape_param(\session)
  session = find_suitable_session(sessions,
    $scope.latest_session, params_session)
  $scope.select_session session

  $scope.session_class = (session) ->
    if $scope.session == session then \active else ''
  $scope.sittings_year_class = (year) ->
    if $scope.sitting_year == year then \active else ''
  $scope.sittings_month_class = (month) ->
    if $scope.sitting_month == month then \active else ''
  $scope.sittings_day_class = (day) ->
    if $scope.sitting_day == day then \active else ''
  $scope.sittings_sitting_class = (sitting) ->
    if $scope.sitting_sitting == sitting then \active else ''
  $scope.committees_class = (committee) ->
    if $scope.committee == committee then \active else ''
  $scope.motion_type_class = (motion_type) ->
    if $scope.motion_type == motion_type then \active else ''

  $scope.committees =
    * type: \YS  name: \院會
    * type: \PRO name: \程序
    * type: \ECO name: \經濟
    * type: \FIN name: \財政
    * type: \IAD name: \內政
    * type: \FND name: \外交國防
    * type: \SWE name: \社服衛環
    * type: \EDU name: \教育文化
    * type: \JUD name: \司法法制
    * type: \TRA name: \交通
  $scope.committees_map = do ->
    map = {}
    $scope.committees.map (committee) ->
      map[committee.type] = committee.name
    map

  $scope.motion_types =
    \全部
    \修法
    \預算
    \查照
    \其他

  $scope.url = ->
    params =
      $scope.session
      $scope.sitting_year
      $scope.sitting_month
      $scope.sitting_day
      $scope.committee
      $scope.sitting_sitting
      $scope.motion_type
    not_prepared = _.any params, (param) ->
      _.is-undefined param
    if not_prepared
      return \載入中...
    protocol = $location.protocol!
    port = $location.port!
    host = $location.host!
    path = $location.path!
    params =
      [\ad,          $scope.session.ad]
      [\session,     $scope.session.session]
      [\year,        $scope.sitting_year]
      [\month,       $scope.sitting_month + 1]
      [\day,         $scope.sitting_day]
      [\committee,   $scope.committee]
      [\extra,       $scope.sitting_sitting.extra]
      [\sitting,     $scope.sitting_sitting.sitting]
      [\motion_type, $scope.motion_type]
    params = params.map (param) ->
      param.join '='
    params = params.join '&'
    "#protocol://#host:#port#path?#params"
