OpenGraph = ->
  http = require \http
  getApi = (path, cb) ->
    opts = do
      hostname: \api.ly.g0v.tw
      method: \GET
      path: '/v0/collections' + path

    console.log JSON.stringify opts

    req = http.request opts, (res) ->
      res.on \data, (chunk) ->
        try
          if res.statusCode is 200
            cb JSON.parse chunk.toString!
          else
            cb {}
        catch e
          cb {}
    req.on \error, (e) ->
      console.log "Request error: #path"
      cb {}, result
    req.end!

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
      result <<< url : 'http://ly.g0v.tw' + req.url
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
      result <<< url: 'http://ly.g0v.tw/sittings/'
      result <<< description: '立法院會議記錄'
      cb result

  og = do
    getMeta : (req, cb) ->
      result = do
        title: '國會大代誌'
        url: 'http://ly.g0v.tw'
        description: '零時政府立法院網頁'
        img: 'http://ly.g0v.tw/img/g0v-logo.png'
      for h in handlers
        return h.handle req, result, cb if req.url and req.url.match h.pattern

      # nothing matched, use def
      cb result
  return og

module.exports = OpenGraph!
