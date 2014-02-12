require! protractor
ptor = protractor.getInstance!

const URL = 'http://localhost:3333/'

describe 'ly.g0v.tw' (,) !->
  beforeEach !-> ptor.get URL

  it 'should automatically redirect to /calendar/today when location hash/fragment is empty' !->
    url <-! ptor.getCurrentUrl!.then
    expect url .toBe URL + 'calendar/today'

describe 'calendar/today' (,) !->
  beforeEach !-> ptor.get URL + 'calendar/today'

  it 'should render calendar when user navigates to /calendar/today' !->
    expect element(by.className 'time').getText! .toMatch /立法院行程/
