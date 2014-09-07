# Declare app level module which depends on filters, and services

angular.module \ly.g0v.tw <[ngGrid app.controllers ly.g0v.tw.controllers app.directives app.filters app.services app.templates ui.state utils monospaced.qrcode]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'motions' do
      url: '/motions'
      templateUrl: 'app/partials/motions.html'
      controller: \LYMotions
    .state 'motions.sitting' do
      url: '/{session}/{sitting}'

    .state 'sittings-new' do
      url: '/sittings-new/{sittingId}'
      templateUrl: 'app/partials/sittings-new.html'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYSittingsNew

    .state 'bills' do
      url: '/bills'
      templateUrl: 'app/partials/bills-hot.html'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYBillsIndex

    .state 'bills-detail' do
      url: '/bills/{billId}'
      templateUrl: 'app/partials/bills.html'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYBills

    .state 'bills-search' do
      url: '/bills-search'
      templateUrl: 'app/partials/bills-search.html'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYBillsSearch

    .state 'bills-detail.compare' do
      url: '/compare/{otherBills}'

    .state 'calendar' do
      url: '/calendar'
      templateUrl: 'app/partials/calendar.html'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYCalendar
    .state 'calendar.period' do
      url: '/{period}'

    .state 'sittings' do
      url: '/sittings'
      templateUrl: 'app/partials/sittings.html'
      controller: \LYSittings
      resolve: _init: <[LYService]> ++ (.init!)
    .state 'sittings.detail' do
      url: '/{sitting}'
    .state 'sittings.detail.video' do
      url: '/video'

    .state 'debates' do
      url: '/debates'
      templateUrl: 'app/partials/debates.html'
      resolve: _init: <[LYService]> ++ (.init!)

    .state 'search' do
      url: '/search'
      templateUrl: 'app/partials/search.html'
      controller: \LYSearch
    .state 'search.target' do
      url: '/{keyword}'

    .state 'about' do
      url: '/about'
      templateUrl: 'app/partials/about.html'
      controller: \About
    # Catch all
  $urlRouterProvider
    .otherwise('/calendar')

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true

.run <[$rootScope $state $stateParams $location $window $anchorScroll]> ++ ($rootScope, $state, $stateParams, $location, $window, $anchorScroll) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.go = -> $location.path it
  $rootScope.config_build = require 'config.jsenv' .BUILD
  $rootScope.$on \$stateChangeSuccess (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$path, title: name
  window.onYouTubeIframeAPIReady = ->
    $rootScope.$broadcast \youtube-ready

  check-mobile = ->
    width = $($window).width!
    $rootScope.is-mobile = width <= 768
  $ $window .resize -> $rootScope.$apply check-mobile
  check-mobile!
