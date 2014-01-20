angular.module 'ly.g0v.tw.controllers' <[ng]>
.controller LYDebates: <[$rootScope $scope $http LYService $sce LYModel]> ++ ($rootScope, $scope, $http, LYService, $sce, LYModel) ->
    $rootScope.activeTab = \debates
    $scope.answer = (answer) ->
        | answer         => $sce.trustAsHtml '已答'
        | otherwise      => $sce.trustAsHtml '未答'
    $scope.asked_by = ({{asked_by}:entity}) ->
        return '' unless asked_by[0]
        return asked_by[0]
    padLeft = (str, length) ->
        if str.length >= length
            return str
        padLeft '0'+str, length
    $scope.source = ({{source}:entity}) ->
        link = source.0.link
        return '' unless link
        str = link[1].toString!.concat padLeft link[2],3 .concat padLeft link[3],2
        href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?'+str+';'.concat padLeft link[4],4 .concat ';'+padLeft link[5],4
        $sce.trustAsHtml """<a href="#{href}" target="_blank">質詢公報</a>"""

    $scope.answers = ({{answers}:entity}) ->
        tmp = ''
        angular.forEach answers, !(value) ->
            if(!value.source[0].text.match /口頭答復/)
                link = value.source[0].link
                str = link[1].toString!.concat padLeft link[2],3 .concat padLeft link[3],2
                href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?'+str+';'.concat padLeft link[4],4 .concat ';'+padLeft link[5],4
                tmp += """<div><a href="#{href}" target="_blank">書面答復</a></div>"""
        if tmp === ''
            tmp += """口頭(見質詢公報)"""
        $sce.trustAsHtml tmp
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
        rowHeight: 90
        data: \debates
        pagingOptions: $scope.pagingOptions,
        i18n: \zh-tw
        columnDefs:
          * field: 'tts_id'
            displayName: \系統號
            width: 80
          * field: 'asked_by'
            displayName: \質詢人
            width: 130
            cellTemplate: """
            <div class="item" legislator="asked_by(row)"></div>
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
          * field: 'interpellation_type'
            displayName: \質詢性質
            width: '*'

    $scope.getData = ({currentPage, pageSize})->
        {paging, entries} <- LYModel.get 'ttsinterpellation' do
            params: do
                sk: (currentPage-1)*pageSize, l: pageSize
        .success
        angular.forEach entries, !(value, key)->
            value.date_asked = new Date value.date_asked
            value.source = value.source
        $scope.debates = entries
    $scope.getData $scope.pagingOptions
