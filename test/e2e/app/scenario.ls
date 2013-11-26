describe 'my app' (,) ->

  beforeEach !->
    browser!navigateTo '/'

  it 'should automatically redirect to /calendar/today when location hash/fragment is empty' !->
    expect browser!location!url! .toBe "/calendar/today"


  describe 'view1' (,) !->

    beforeEach !->
      browser!navigateTo '#/calendar/today'

    it 'should render view1 when user navigates to /view1' ->
      expect element('[ui-view] .time:first').text! .toMatch /立法院行程/
