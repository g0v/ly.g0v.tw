angular.module 'app.controllers.search' []
.controller LYSearch: <[$rootScope $scope $state]> ++ ($rootScope, $scope, $state) ->
  $scope.$watch '$state.params.keyword' ->
    $scope.keyword = $state.params.keyword
    return unless $state.params.keyword
    doSearch $scope.keyword
  doSearch = (keyword)->
    $scope.results = for i in [1 2 3]
      i + keyword

