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
    choice = 0 
    searchChoice =
      * name: \bills
        q: JSON.stringify do
          summary: $matches: keyword
      * name: \amendments
        q: JSON.stringify do
          name: $matches: keyword
    {paging, entries} <- LYModel.get searchChoice[choice].name, do
      params: do
        q: searchChoice[choice].q
        l: $scope.limit
        sk: $scope.sk
    .success
    console.log entries
    $scope.sk += $scope.limit
    cb entries   
