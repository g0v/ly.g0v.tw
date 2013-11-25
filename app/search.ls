angular.module 'app.controllers.search' []
.controller LYSearch: <[$rootScope $scope $state $timeout LYModel]> ++ ($rootScope, $scope, $state, $timeout, LYModel) ->
  $scope.limit = 12
  $scope.sk = 0
  $scope.results = []
  $scope.$watch '$state.params.keyword' ->
    $scope.sk = 0
    $scope.keyword = $state.params.keyword
    return unless $state.params.keyword
    {id} <- LYModel.get 'laws' do
      params: do
        q: JSON.stringify do
          name: $matches: $state.params.keyword
        f: JSON.stringify do
          id: 1
        fo: true
    .success
    $scope.law-id = id
    $scope.results = []
    $scope.moreResults!
  $scope.moreResults = ->
    $scope.busy = true
    res <- doSearch $scope.law-id
    for obj in res
      data <- LYModel.get "bills/"+obj.bill_ref .success
      $scope.results.push data
    $scope.stopDetect = true if res.length is 0
    $scope.busy = false

  doSearch = (law-id, cb)->
    {paging, entries} <- LYModel.get 'amendments' do
      params: do
        q: JSON.stringify do
          law_id: law-id
        f: JSON.stringify do
          bill_ref: 1
        l: $scope.limit
        sk: $scope.sk
    .success
    $scope.sk += $scope.limit
    cb entries
