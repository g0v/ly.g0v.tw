chai.should!

describe 'bills' ->

  before-each module 'ly.g0v.tw'

  describe 'LYBillsIndex' (void) ->

    controller_name = @title

    var create-controller
    var $scope, $state # in controller LYBills
    var $http-backend, $location # for inject
    var ly_api,
      get_analytics_cassette,
      get_bills_snapshot,
      get_bill_cassette # helper

    before-each inject (
       <[$state $location $rootScope $controller $httpBackend]>
    ) ++ (state, location, rootScope, controller, httpBackend) ->

      # in controller LYBills
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
      ly_api := (path) ->
        "http://api.ly.g0v.tw/v0/collections#path"
      get_analytics_cassette := (date) ->
        window.__fixtures__["test/unit/fixtures/cassettes/bills_hot/#date/analytics"]
      get_bills_snapshot := (date) ->
        window.__fixtures__["test/unit/fixtures/snapshots/bills_hot/#date/current_bills"]
      get_bill_cassette := (date, bill) ->
        dir = new RegExp "test/unit/fixtures/cassettes/bills_hot/#date/#{bill.ref}/(\\w+)"
        fixtures = {}
        for path, data of window.__fixtures__
          if path.match dir
            fixtures[that[1]] = data
        fixtures

    it 'steps bar of bill' ->
      bills_hot_dates = [
        * date: '2014-08-15' # These hot bills are presented in webpage on 2014/8/15.
          bills:
            * id: '1021125070202300' ref: '1073L15722'
            * id: '1010903071000300' ref: '1061G13322'
      ]
      $location.path '/bills'
      Timecop = window.Timecop
      Timecop.install!
      bills_hot_dates.map ({date, bills}) ->
        [year, month, day] = date.match /\d+/g
        Timecop.freeze new Date year, month - 1, day
        cassette = get_analytics_cassette date
        $http-backend.when 'GET', ly_api "/analytics?q=%7B%22name%22:%22bill%22%7D"
                     .respond -> [200,  cassette]
        bills.map (bill) ->
          cassette = get_bill_cassette date, bill
          code = cassette['report'].error ? 404 : 200
          $http-backend.when 'GET', ly_api "/bills/#{bill.ref}"
                       .respond -> [200,  cassette['motions']]
          $http-backend.when 'GET', ly_api "/bills?fo=true&q=%7B%22report_of%22:%7B%22$contains%22:%22#{bill.id}%22%7D%7D"
                       .respond -> [code, cassette['report']]
          $http-backend.when 'GET', ly_api "/ttsmotions?q=%7B%22bill_refs%22:%7B%22$contains%22:%22#{bill.ref}%22%7D%7D&s=%7B%22date%22:-1%7D"
                       .respond -> [200,  cassette['ttsmotions']]
        controller = create-controller!
        $http-backend.flush!
        snapshot = get_bills_snapshot date
        $scope.current-bills.should.deep.eq snapshot
        Timecop.return-to-present!
      Timecop.uninstall!

  describe 'LYBills' (void) ->

    controller_name = @title

    var create-controller
    var $scope, $state # in controller LYBills
    var $http-backend, $location # for inject
    var ly_api, get_cassette, get_snapshot # helper

    before-each inject (
       <[$state $location $rootScope $controller $httpBackend]>
    ) ++ (state, location, rootScope, controller, httpBackend) ->

      # in controller LYBills
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
      ly_api := (path) ->
        "http://api.ly.g0v.tw/v0/collections#path"
      get_cassette := (bill) -> get_fixture 'cassettes', bill
      get_snapshot := (bill) -> get_fixture 'snapshots', bill
      get_fixture = (type, bill) ->
        dir = new RegExp "test/unit/fixtures/#type/bills/#{bill.ref}/(\\w+)"
        fixtures = {}
        for path, data of window.__fixtures__
          if path.match dir
            fixtures[that[1]] = data
        fixtures

    it 'steps bar of bill' ->
      bills =
        * id: '1020926070201400' ref: '335L15406'
        * id: '1010224070200500' ref: '468L12892'
        * id: '1020624071002700' ref: '915G13287-1'
        * id: '1020104070200100' ref: '1618L14627'
        * id: '1020619070200100' ref: '184L15146-1'
        * id: '1020918070200300' ref: '882L15375'
        * id: '1021125070202300' ref: '1073L15722'
        * id: '1020930070201200' ref: '1374L15430'
        * id: '1010411070200600' ref: '1788L13286'
        * id: '1020415070200800' ref: '1559L14887'
        * id: '1021007070200500' ref: '1013L15476'
        * id: '1010329070201800' ref: '882L13190'
        * id: '1020527070200300' ref: '979L15307'
        * id: '1020918070100100' ref: '471G14754'
      bills.map (bill) ->
        $location.path "/bills/#{bill.ref}"
        $state.params.bill-id = bill.ref
        cassette = get_cassette bill
        code = cassette['report'].error ? 404 : 200
        $http-backend.when 'GET', ly_api "/bills/#{bill.ref}"
                     .respond -> [200,  cassette['motions']]
        $http-backend.when 'GET', ly_api "/bills?fo=true&q=%7B%22report_of%22:%7B%22$contains%22:%22#{bill.id}%22%7D%7D"
                     .respond -> [code, cassette['report']]
        $http-backend.when 'GET', ly_api "/bills/#{bill.ref}/data"
                     .respond -> [200,  cassette['data']]
        $http-backend.when 'GET', ly_api "/ttsmotions?q=%7B%22bill_refs%22:%7B%22$contains%22:%22#{bill.ref}%22%7D%7D&s=%7B%22date%22:-1%7D"
                     .respond -> [200,  cassette['ttsmotions']]
        controller = create-controller!
        $http-backend.flush!
        snapshot = get_snapshot bill
        $scope.steps.should.deep.eq snapshot['steps']
