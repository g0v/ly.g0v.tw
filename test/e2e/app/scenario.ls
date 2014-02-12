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
    expect element(by.className \time).getText! .toMatch /立法院行程/

describe 'bills' !->
  describe 'articles' (,) !->
    # only the following bill has both original and proposed section
    # http://logbot.g0v.tw/channel/g0v.tw/2014-02-07/481
    # but 492 elements are too many to test
    it 'should have labels' !->
      browser.get URL + 'bills/970L19045'
      element
        .all by.xpath "//*[contains(@id, 'original') or contains(@id, 'proposed')]"
        .then !->
          # TODO: speed up getText
          for elem in it => elem.getText!then !->
            expect it .not.toBe \§
            expect it .not.toBe \§undefined
