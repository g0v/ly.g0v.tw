# Declare app level module which depends on filters, and services

angular.module \ly.g0v.tw <[ngGrid app.controllers ly.g0v.tw.controllers app.directives app.filters app.services app.templates ui.state utils monospaced.qrcode]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'motions' do
      url: '/motions'
      templateUrl: 'app/partials/motions.jade'
      controller: \LYMotions
    .state 'motions.sitting' do
      url: '/{session}/{sitting}'

    .state 'sittings-new' do
      url: '/sittings-new/{sittingId}'
      templateUrl: 'app/partials/sittings-new.jade'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYSittingsNew

    .state 'bills' do
      url: '/bills/{billId}'
      templateUrl: 'app/partials/bills.jade'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYBills

    .state 'bills.compare' do
      url: '/compare/{otherBills}'

    .state 'calendar' do
      url: '/calendar'
      templateUrl: 'app/partials/calendar.jade'
      resolve: _init: <[LYService]> ++ (.init!)
      controller: \LYCalendar
    .state 'calendar.period' do
      url: '/{period}'

    .state 'sittings' do
      url: '/sittings'
      templateUrl: 'app/partials/sittings.jade'
      controller: \LYSittings
      resolve: _init: <[LYService]> ++ (.init!)
    .state 'sittings.detail' do
      url: '/{sitting}'
    .state 'sittings.detail.video' do
      url: '/video'

    .state 'debates' do
      url: '/debates'
      templateUrl: 'app/partials/debates.jade'
      resolve: _init: <[LYService]> ++ (.init!)

    .state 'search' do
      url: '/search'
      templateUrl: 'app/partials/search.jade'
      controller: \LYSearch
    .state 'search.target' do
      url: '/{keyword}'

    .state 'about' do
      url: '/about'
      templateUrl: 'app/partials/about.jade'
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
  $rootScope.config_build = window.global.config.BUILD
  $rootScope.$on \$stateChangeSuccess (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$url, title: name
  window.onYouTubeIframeAPIReady = ->
    $rootScope.$broadcast \youtube-ready

  check-mobile = ->
    width = $($window).width!
    $rootScope.is-mobile = width <= 768
  $ $window .resize -> $rootScope.$apply check-mobile
  check-mobile!
