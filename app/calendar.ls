angular.module 'app.controllers.calendar' []
.controller LYCalendar: <[$rootScope $scope $state $http LYService LYModel $sce]> ++ ($rootScope, $scope, $state, $http, LYService, LYModel, $sce) ->
      today = moment!startOf('day')
      committees = $rootScope.committees

      # XXX: unused.  use filter instead
      $scope.type = 'sitting'
      $rootScope.activeTab = \calendar
      $scope.weeksOpts = buildWeeks 49 # 49 is 7 weeks, just a random number
      $scope.weeksOpts.unshift {
        start: moment today .startOf \day .add 'days' -1
        end: moment today .startOf \day .add 'days', 1
        label: \今日  # if today is 8th, we request query by date > 7 and date < 9
        name: \today
      }

      $scope.$watch 'weeks' (newV, oldV)->
        return unless $scope.weeks
        $state.transitionTo 'calendar.period', {period: $scope.weeks.name} if newV and oldV and newV.label!==oldV.label

      $scope.change = !(type) ->
        $scope.type = type
        updatePage!

      $scope.$watch '$state.params.period' ->
        if not $state.params.period
          $state.transitionTo 'calendar.period', {period: $scope.weeksOpts[0].name}
          return
        updatePage!

      function buildWeeks(first)
        weeks = for i from 0 to first by 7
          do ->
            opt = {
              start: moment today .day 0 - i
              end: moment today .day 0 - i + 7
            }
            opt <<< label: opt.start.format "YYYY:  MM-DD" + ' to ' + opt.end.format "MM-DD"
            opt <<< name: opt.start.format "YYYY-MM-DD" + '_' + opt.end.format "YYYY-MM-DD"
        return weeks

      updatePage = ->
        parseState $state.params.period
        [start, end, name] = if $state.current.name is /^calendar.period/ =>  parseState $state.params.period
        if not start.isValid! or not end.isValid! or start > end
          [start, end, name] = [$scope.weeksOpts[0].start, $scope.weeksOpts[0].end, \today]
        [strS, strE] = [start, end].map (.format 'YYYY-MM-DD')
        name ?= strS + "_" + strE
        $state.transitionTo 'calendar.period', {period: name} if $state.current.name!==name
        getData $scope.type, strS, strE
        updateDropdownOptions start, end

      updateDropdownOptions = (start, end) ->
        [first] = for opt in $scope.weeksOpts when +opt.start is +start and +opt.end is +end
          opt
        $scope.weeks = first

      parseState = (str) ->
        if str is /today/ or !str
          return [$scope.weeksOpts[0].start, $scope.weeksOpts[0].end, $scope.weeksOpts[0].name]
        r = str.split \_ .map (s)-> moment s,'YYYY-MM-DD'
        r.push str
        return r

      insert = (group, entry) ->
        # same sitting id but different time, regards as different entry
        key = entry.date + entry.time_start + entry.time_end + entry.sitting_id
        group[key] ?= entry

        # use revised entry
        group[key] = if entry.id > group[key].id => entry else group[key]

      getSortedValue = (obj) ->
        keys = Object.keys obj .sort!
        array = for k in keys when obj[k]
          obj[k]
        return array

      isOnAir = (date, start, end) ->
        d = moment date .startOf \day
        [s, e] = [start, end]map -> moment it, 'HH:mm:ss'
        return +today is +d and s <= moment! <=e

      getData = (type, start, end)->
        {paging, entries} <- LYModel.get 'calendar' do
            params: do
                s: JSON.stringify date: 1, time_start: 1
                q: JSON.stringify do
                    date: $gt: start, $lt: end
                    type: type
                # XXX  shame on me
                l: 1000
        .success
        group = {}
        entries.map ->
          it <<< formatDate: moment(it.date).zone('+00:00').format('MMM Do, YYYY')
          it <<< primaryCommittee: it.committee?0 or 'YS'
          it <<< onair: isOnAir it.date, it.time_start, it.time_end
          group[it.primaryCommittee] ?= {}
          insert group[it.primaryCommittee], it
        sorted = {}
        for name, entries of group
          sorted[name] = getSortedValue group[name]
        $scope.group = sorted
        $scope.groupNum = Object.keys $scope.group .length

