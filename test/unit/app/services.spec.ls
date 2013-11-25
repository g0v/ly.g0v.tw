describe "service" ->

  var $httpBackend
  beforeEach module "app.services"
  describe "mly" (,)->
    beforeEach inject (_$httpBackend_) !->
      $httpBackend := _$httpBackend_
      $httpBackend.expectGET '/data/mly-8.json'
      .respond [name: \丁守中, party: \KMT]

    it "LYService" inject (LYService) !->
      LYService.init!
      $httpBackend.flush!
      expect(LYService).not.to.equal(null);
      expect LYService.parseParty \中國國民黨 .to.equal \KMT
      expect LYService.resolveParty \丁守中 .to.equal \KMT
