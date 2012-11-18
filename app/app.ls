# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

App = angular.module \app <[ngCookies ngResource app.controllers app.directives app.filters app.services scroll]>

App.config <[$routeProvider $locationProvider]> +++ ($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/sitting templateUrl: \/partials/app/sitting.html
    # Catch all
    .otherwise redirectTo: \/sitting

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true
