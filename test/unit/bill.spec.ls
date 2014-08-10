chai.should!

describe 'bills' ->

  before-each module 'ly.g0v.tw'

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
