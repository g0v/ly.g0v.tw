angular.module 'ly.g0v.tw.controllers' <[ng]>
.controller LYDebates: <[$rootScope $scope $http LYService $sce]> ++ ($rootScope, $scope, $http, LYService, $sce) ->
    $rootScope.activeTab = \debates
    $scope.answer = (answer) ->
        | answer         => '已答'
        | otherwise      => '未答'
    $scope.mly = ({{mly}:entity}) ->
        return '' unless mly[0]
        party = LYService.resolveParty mly[0]
        avatar = CryptoJS.MD5 "MLY/#{mly[0]}" .toString!
        $sce.trustAsHtml(mly[0] + """<img class="avatar small #party" src="http://avatars.io/50a65bb26e293122b0000073/#{avatar}?size=small" alt="#{mly[0]}">""")
    padLeft = (str, length) ->
        if str.length >= length
            return str
        padLeft '0'+str, length
    $scope.source = ({{{link}:source}:entity}) ->
        return '' unless link
        str = link[1].toString!.concat padLeft link[2],3 .concat padLeft link[3],2
        href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?'+str+';'.concat padLeft link[4],4 .concat ';'+padLeft link[5],4
        $sce.trustAsHtml("""<a href="#{href}" target="_blank">質詢公報</a>""");

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
        $sce.trustAsHtml(tmp)
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
            <div ng-bind-html="mly(row)"></div>
            """
          * field: 'source'
            displayName: \質詢公報
            width: 80
            cellTemplate: """
            <div ng-bind-html="source(row)"></div>
            """
          * field: 'answers'
            displayName: \答復公報
            width: 100
            cellTemplate: """
            <div ng-bind-html="answers(row)"></div>
            """
          * field: 'summary'
            displayName: \案由
            visible: false
          * field: 'answered'
            displayName: \答復
            width: '50'
            cellTemplate: """
            <div ng-bind-html="answer(row)"></div>
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
