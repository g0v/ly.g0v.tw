# Declare app level module which depends on filters, and services

angular.module('scroll', []).value('$anchorScroll', angular.noop)

angular.module \ly.g0v.tw <[ngGrid app.controllers app.directives app.filters app.services scroll partials ui.state utils]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'motions' do
      url: '/motions'
      templateUrl: '/partials/motions.html'
      controller: \LYMotions
    .state 'motions.detail' do
      url: 'YS/{ys}'

    .state 'bill' do
      url: '/bill/{billId}'
      templateUrl: '/partials/bill.html'
      controller: \LYBill

    .state 'calendar' do
      url: '/calendar'
      templateUrl: '/partials/calendar.html'
    .state 'sitting' do
      url: '/sitting'
      templateUrl: '/partials/sitting.html'
    .state 'about' do
      url: '/about'
      templateUrl: '/partials/about.html'
    # Catch all
  $urlRouterProvider
    .otherwise('/motions')

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true
