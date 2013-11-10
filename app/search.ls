angular.module 'app.controllers.search' []
.controller LYSearch: <[$rootScope $scope $state LYModel]> ++ ($rootScope, $scope, $state, LYModel) ->
  $scope.limit = 42
  $scope.$watch '$state.params.keyword' ->
    $scope.keyword = $state.params.keyword
    return unless $state.params.keyword
    doSearch $scope.keyword
  doSearch = (keyword)->
    {paging, entries} <- LYModel.get 'bills' do
      params: do
        q: JSON.stringify do
          summary: $matches: keyword
        l: 42
    .success
    $scope.results = entries

