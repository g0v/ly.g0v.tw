describe 'ly.g0v.tw' (,) ->

  beforeEach !->
    browser!navigateTo '/'

  it 'should automatically redirect to /calendar/today when location hash/fragment is empty' !->
    expect browser!location!url! .toBe "/calendar/today"


  describe 'calendar/today' (,) !->

    beforeEach !->
      browser!navigateTo '#/calendar/today'

    it 'should render calendar when user navigates to /calendar/today' ->
      expect element('[ui-view] .time:first').text! .toMatch /立法院行程/
