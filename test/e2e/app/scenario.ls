require! protractor
const URL = 'http://localhost:3333/'

describe 'ly.g0v.tw' (,) !->
  var ptor

  beforeEach !->
    ptor := protractor.getInstance!
    ptor.get URL

  it 'should automatically redirect to /calendar/today when location hash/fragment is empty' !->
    url <-! ptor.getCurrentUrl!.then
    expect url .toBe URL + 'calendar/today'

describe 'calendar/today' (,) !->
  var ptor

  beforeEach !->
    ptor := protractor.getInstance!
    ptor.get URL + 'calendar/today'

  it 'should render calendar when user navigates to /calendar/today' !->
    # FIXME: How to implement it?
    #expect element('[ui-view] .time:first').text! .toMatch /立法院行程/
