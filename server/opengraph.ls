OpenGraph = ->
  make-url = (req, path) -> req.protocol + '://' + req.headers.host + path
  request = require \request
  getApi = (path, cb) ->
    err, resp, body <- request.get 'http://api.ly.g0v.tw/v0/collections' + path
    try
      if resp.statusCode is 200
        cb JSON.parse body
      else if err
        cb {}, result
    catch e
      cb {}

  handlers = []

  handlers.push do
    # path: /
    pattern: /^\/$/
    handle: (req, result, cb)->
      # root path, use default data
      cb result

  handlers.push do
    # path: /bills/1108L15866
    pattern: /^\/bills.*/
    handle: (req, result, cb) ->
      json <- getApi req.url
      base req.protocol + '://' + req.headers.host
      result <<< url: make-url req, req.url
      desc = ''
      desc += json.summary if json.summary
      if json.abstract
        desc += json.abstract
      else if json.proposed_by
        desc += '提案人：' + json.proposed_by
      result <<< description: desc if desc
      cb result

  handlers.push do
    # path: /sittings
    pattern: /^\/sittings[/]?$/
    handle: (req, result, cb)->
      result <<< title: '國會大代誌'
      result <<< url: make-url req, '/sittings/'
      result <<< description: '立法院會議記錄'
      cb result

  handlers.push do
    # path: /sittings/08-04-ECO-04
    pattern: /^\/sittings\/.+/
    handle: (req, result, cb) ->
      json <- getApi req.url
      result <<< title: json.name if json.name
      result <<< url: make-url req, req.url if req.url
      result <<< description: json.summary if json.summary
      cb result

  handlers.push do
    # path: /calendar*
    pattern: /^\/calendar.*$/
    handle: (req, result, cb) ->
      result <<< title: '國會大代誌'
      result <<< url: make-url req, req.url if req.url
      result <<< description: '立法院行程與預報'
      console.log JSON.stringify result
      cb result

  handlers.push do
    # path: /debates*
    pattern: /^\/debates.*$/
    handle: (req, result, cb) ->
      result <<< title: '國會大代誌'
      result <<< url: make-url req, req.url if req.url
      result <<< description: '立法院質詢紀錄'
      console.log JSON.stringify result
      cb result

  og = do
    getMeta : (req, cb) ->
      result = do
        title: '國會大代誌'
        url: make-url req, '/'
        description: '零時政府立法院網頁'
        img: make-url req, '/img/g0v-2line-white-s.png'
      for h in handlers when req.url?match h.pattern
        return h.handle req, result, cb

      # nothing matched, use def
      cb result
  return og

module.exports = OpenGraph!
