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
    # http://logbot.g0v.tw/channel/g0v.tw/2014-02-07/481
    it 'should have labels' !->
      browser.get URL + 'bills/1150L15359'
      element
        .all by.xpath "//*[contains(@id, 'original') or contains(@id, 'proposed')]"
        .then !->
          expect it.length .toBe 492
          for elem in it => elem.getText!then !->
            expect it .not.toBe \§
            expect it .not.toBe \§undefined
    , 300000ms # TODO: speed up getText
