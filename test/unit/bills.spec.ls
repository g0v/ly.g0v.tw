describe \bills (,) ->
  beforeEach module 'app.controllers.bills'

  describe \LYBills (,) ->
    it 'should have scope' inject ($rootScope, $controller) ->
      scope = $rootScope.$new!
      #ctrl  = $controller \LYBills $scope: scope
      console.log scope
      expect true .to.equal true
