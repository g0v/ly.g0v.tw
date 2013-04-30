# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

App = angular.module \app <[ngGrid app.controllers app.directives app.filters app.services scroll partials]>

App.config <[$routeProvider $locationProvider]> ++ ($routeProvider, $locationProvider, config) ->
  $routeProvider
    .when \/motions templateUrl: \/partials/motions.html
    .when \/bill templateUrl: \/partials/bill.html
    .when \/calendar templateUrl: \/partials/calendar.html
    .when \/bill/:billId templateUrl: \/partials/bill.html
    .when \/sitting templateUrl: \/partials/sitting.html
    .when \/about templateUrl: \/partials/about.html
    # Catch all
    .otherwise redirectTo: \/motions

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true

window.App = App
