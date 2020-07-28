chai.should!

describe 'bills-search' ->

  before-each module 'ly.g0v.tw'

  describe 'LYBillsSearch' (void) ->

    controller_name = @title

    var create-controller
    var $scope, $state # in controller LYBillsSearch
    var $http-backend, $location # for inject

    before-each inject (
       <[$state $location $rootScope $controller $httpBackend]>
    ) ++ (state, location, rootScope, controller, httpBackend) ->

      # in controller LYBillsSearch
      $state := state
      $scope := root-scope.$new!
      create-controller := ->
        controller controller_name, {$scope, $state}

      # for inject
      $location := location
      $http-backend := httpBackend
      $http-backend.when 'GET', '/data/mly-8.json'
      .respond [name: \丁守中, party: \KMT]

    # helper
    ly_api = (path) ->
      "http://api.ly.g0v.tw/v0/collections/#{escape_path path}"
    base = 'test/unit/fixtures/cassettes/bills_search'
    get_latest_sitting_url = 'sittings?l=1'
    get_latest_sitting_cassette = (date) ->
      url = get_latest_sitting_url
      window.__fixtures__["#base/#date/#{unescape_path url}"]

    get_session_period_url = (order, ad, session) ->
      "calendar?l=1&q={\"ad\":#ad,\"session\":#session}&s={\"date\":#order}"
    get_session_period_cassette = (date, url) ->
      window.__fixtures__["#base/#date/#{unescape_path url}"]

    get_session_sittings_url = (ad, session) ->
      "sittings?l=500&q={\"ad\":#ad,\"session\":#session}"
    get_session_sittings_cassette = (date, url) ->
      window.__fixtures__["#base/#date/#{unescape_path url}"]

    snapshots_base = 'test/unit/fixtures/snapshots/bills_search'
    get_snapshots = (date) ->
      window.__fixtures__["#snapshots_base/#date/scope"]

    escape_path = (path) ->
      path = path.replace /{/g, '%7B'
      path = path.replace /"/g, '%22'
      path = path.replace /}/g, '%7D'
      path

    unescape_path = (path) ->
      path = path.replace /\?/, ' '
      path = path.replace /"/g, \་
      path.replace /,/g, \¸

    test_scope_variables = <[
      today
      latest_session
      other_sessions
      session
      committees
      committees_map
      committee
      motion_types
      sittings_year
      sitting_year
      sittings_month
      sitting_month
      sittings_day
      sitting_day
      sittings_sitting
      sitting_sitting
      sitting_sitting_summary
      motions
      motion_type
      selected_motions
    ]>

    save_scope_variables = (date) ->
      scope = {}
      for k, v of $scope
        pattern = new RegExp "^(#{test_scope_variables.join '|'})$"
        if pattern.test k
          scope[k] = v
      $.ajax do
        type: 'POST'
        url: 'http://localhost:9877/record'
        data:
          path: "#snapshots_base/#date/scope.json"
          json: JSON.stringify scope
        data-type: 'text'

    it 'bills-search' ->
      dates = [
        * date: '2014-09-09'
      ]
      $location.path '/bills-search'
      Timecop = window.Timecop
      Timecop.install!
      dates.map ({date}) ->
        Timecop.freeze moment(date, 'YYYY-MM-DD').to-date!
        latest_sitting_cassette = get_latest_sitting_cassette date
        $http-backend.when 'GET', ly_api(get_latest_sitting_url)
                     .respond -> [200, latest_sitting_cassette]
        latest_sitting = latest_sitting_cassette.entries[0]
        [latest_sitting.session to 1 by -1].map (session) ->
          url = get_session_period_url 1, latest_sitting.ad, session
          cassette = get_session_period_cassette date, url
          $http-backend.when 'GET', ly_api(url)
                       .respond -> [200, cassette]
          url = get_session_period_url -1, latest_sitting.ad, session
          cassette = get_session_period_cassette date, url
          $http-backend.when 'GET', ly_api(url)
                       .respond -> [200, cassette]
        url = get_session_sittings_url(
          latest_sitting.ad, latest_sitting.session)
        cassette = get_session_sittings_cassette date, url
        $http-backend.when 'GET', ly_api(url)
                     .respond -> [200, cassette]
        controller = create-controller!
        $http-backend.flush!

        snapshots = get_snapshots date
        test_scope_variables.map (variable) ->
          $scope[variable].should.deep.eq snapshots[variable]

        # click first of other sessions button
        #session = snapshots.other_sessions[0]
        #$scope.select_session session
        #url = get_session_sittings_url(
        #  latest_sitting.ad, latest_sitting.session - 1)
        #cassette = get_session_sittings_cassette date, url
        #$http-backend.when 'GET', ly_api(url)
        #             .respond -> [200, cassette]
        #$http-backend.flush!

        Timecop.return-to-present!
      Timecop.uninstall!
