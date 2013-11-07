angular.module 'app.controllers.calendar' []
.controller LYCalendar: <[$rootScope $scope $state $http LYService LYModel $sce]> ++ ($rootScope, $scope, $state, $http, LYService, LYModel, $sce) ->
      today = moment!startOf('day')
      committees = $rootScope.committees

      # XXX: unused.  use filter instead
      $scope.type = 'sitting'
      $rootScope.activeTab = \calendar
      $scope.weeksOpts = buildWeeks 49 # 49 is 7 weeks, just a random number
      $scope.weeksOpts.unshift {
        start: moment today .add 'days', -1 # why not 0?
        end: moment today .add 'days', 1
        label: \今日
      }
      $scope.weeks = $scope.weeksOpts[0]

      $scope.$watch 'weeks' ->
        [start, end] = [$scope.weeks.start, $scope.weeks.end].map (.format "YYYY-MM-DD")
        $state.transitionTo 'calendar.period', {period: start + "_" + end}

      $scope.change = !(type) ->
        $scope.type = type
        [start, end] = [$scope.weeks.start, $scope.weeks.end].map (.format "YYYY-MM-DD")
        $state.transitionTo 'calendar.period', {period: start + "_" + end}
        updatePage!

      $scope.$watch '$state.params.period' ->
        updatePage!

      function buildWeeks(first)
        weeks = for i from 0 to first by 7
          do ->
            opt = {
              start: moment today .day 0 - i
              end: moment today .day 0 - i + 7
            }
            opt <<< label: opt.start.format "YYYY:  MM-DD" + ' to ' + opt.end.format "MM-DD"
        return weeks

      updatePage = ->
        [start, end] = if $state.current.name is /^calendar.period/ =>  parseState $state.params.period
        if not start.isValid! or not end.isValid! or start > end
          [start, end] = [$scope.weeksOpts[0].start, $scope.weeksOpts[0].end]
        f = start.format "YYYY-MM-DD" + "_" + end.format "YYYY-MM-DD"
        $state.transitionTo 'calendar.period', {period: f}
        getData $scope.type, start, end

      parseState = (str) ->
        str.split \_ .map (s)-> moment s,'YYYY-MM-DD'

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
        [s, e] = [start, end]map -> moment "#{d.format 'YYYY-MM-DD'}"
        return +today is +d and s <= moment! <=e

      getData = (type, start, end)->
        {paging, entries} <- LYModel.get 'calendar' do
            params: do
                s: JSON.stringify date: 1, time: 1
                q: JSON.stringify do
                    date: $gt: start, $lt: end
                    type: type
                # XXX  shame on me
                l: 1000
        .success
        group = {}
        entries.map ->
          # XXX: why should we remove the timezone postfix 'Z' to let the statement works?
          # +(moment('2013-11-03T03:48:00.000Z')).startOf('day') === +(moment('2013-11-03T23:48:00.000Z')).startOf('day')
          it.date -= /Z/
          it <<< formatDate: moment(it.date).format('MMM Do, YYYY')
          it <<< primaryCommittee: it.committee?0 or 'YS'
          it <<< onair: isOnAir it.date, it.time_start, it.time_end
          group[it.primaryCommittee] ?= {}
          insert group[it.primaryCommittee], it
        sorted = {}
        for name, entries of group
          sorted[name] = getSortedValue group[name]
        $scope.group = sorted

      /* comment out this block since we are not using ng-grid.
      $scope.committee = ({{committee}:entity}, col) ->
          return '院會' unless committee
          res = for c in committee
              """<img class="avatar small" src="http://avatars.io/50a65bb26e293122b0000073/committee-#{c}?size=small" alt="#{committees[c]}">""" + committees[c]
          $sce.trustAsHtml res.join ''

      $scope.chair = ({{chair}:entity}, col) ->
          return '' unless chair
          party = LYService.resolveParty chair
          avatar = CryptoJS.MD5 "MLY/#{chair}" .toString!
          $sce.trustAsHtml chair + """<img class="avatar small #party" src="http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small" alt="#{chair}">"""

      $scope.onair = ({{date,time}:entity}) ->
          d = moment date .startOf \day
          return false unless +today is +d
          [start,end] = if time => (time.split \~ .map -> moment "#{d.format 'YYYY-MM-DD'} #it")
          else [entity.time_start,entity.time_end]map -> moment "#{d.format 'YYYY-MM-DD'} #it"
          start <= moment! <= end

      $scope.gridOptions = {+showFilter, +showColumnMenu, +showGroupPanel, +enableHighlighting,
      -groupsCollapsedByDefault, +inlineAggregate, +enableRowSelection} <<< do
          groups: <[primaryCommittee]>
          rowHeight: 65
          data: \calendar
          i18n: \zh-tw
          aggregateTemplate: """
          <div ng-click="row.toggleExpand()" ng-style="rowStyle(row)" class="ngAggregate" ng-switch on="row.field">
            <span ng-switch-when="primaryCommittee" class="ngAggregateText" ng-bind-html="row.label | committee"></span>
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
              <div ng-bind-html="row.getProperty(col.field) | committee"></div>
              """
            * field: 'committee'
              visible: false
              displayName: \委員會
              width: 130
              cellTemplate: """
              <div ng-bind-html="row.getProperty(col.field) | committee"></div>
              """
            * field: 'chair'
              displayName: \主席
              width: 130
              cellTemplate: """
              <div ng-bind-html="chair(row)"></div>
              """
            * field: 'date'
              cellFilter: 'date: mediumDate'
              width: 100px
              displayName: \日期
            * field: 'time'
              width: 100px
              displayName: \時間
              cellTemplate: """<div ng-class="{onair: onair(row)}"><div class="ngCellText">{{row.getProperty('time_start')}}-<br/>{{row.getProperty('time_end')}}</div></div>
              """
            * field: 'name'
              displayName: \名稱
              width: 320px
              cellTemplate: """<div class="ngCellText"><a ng-href="/sittings/{{row.getProperty('sitting_id')}}">{{row.getProperty(col.field)}}</a></div>"""
            * field: 'summary'
              displayName: \議程
              cellClass: \summary
              width: '*'

      $scope.$watch 'height' (->
          $ '.grid' .height $scope.height - 65
          options = $scope.gridOptions
          options.$gridServices.DomUtilityService.RebuildGrid options.$gridScope, options.ngGrid
      ), false
      */

