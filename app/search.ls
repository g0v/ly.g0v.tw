angular.module 'app.controllers.search' []
.controller LYSearch: <[$rootScope $scope $state LYModel]> ++ ($rootScope, $scope, $state, LYModel) ->
  $scope.limit = 12
  $scope.sk = 0
  $scope.results = []
  $scope.$watch '$state.params.keyword' ->
    $scope.keyword = $state.params.keyword
    return unless $state.params.keyword
    $scope.results = []
    $scope.moreResults!

  $scope.moreResults = ->
    $scope.busy = true
    res <- doSearch $scope.keyword
    $scope.results ++= res
    $scope.stopDetect = true if res.length is 0
    $scope.busy = false
  doSearch = (keyword, cb)->
    {paging, entries} <- LYModel.get 'bills' do
      params: do
        q: JSON.stringify do
          summary: $matches: keyword
        l: $scope.limit
        sk: $scope.sk
    .success
    $scope.sk += $scope.limit
    cb entries

