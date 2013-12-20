OpenGraph = ->
  og = do
    getMeta : (req, cb) ->
      result = do
        title: '國會大代誌'
        url: 'http://ly.g0v.tw'
        description: '零時政府立法院網頁'
        img: 'http://ly.g0v.tw/img/g0v-logo.png'
      cb result
  return og

module.exports = OpenGraph!
