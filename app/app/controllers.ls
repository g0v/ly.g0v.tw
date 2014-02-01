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
        """<img class="avatar small" src="http://avatars.io/52ed1f85c747b48148000053/committee-#{c}?size=small" alt="#{committees[c]}">""" + committees[c]
    res.join ''


angular.module 'app.controllers' <[app.controllers.calendar app.controllers.sittings app.controllers.sittings-new app.controllers.bills app.controllers.search ng]>
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
