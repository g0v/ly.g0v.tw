OpenGraph = ->
  http = require \http
  opts = do
    hostname: \api.ly.g0v.tw
    method: \GET

  getApi = (path, cb) ->
    opts <<< path: '/v0/collections' + path

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
