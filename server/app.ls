require! <[express ./opengraph]>

export lyserver = (app = express!) ->
  env-param = if process.env.NODE_ENV is \production
    {googleAnalytics: 'UA-41326468-1', env: \production}
  else {}

  defHandler = (req, res) ->
    res.render 'index.jade' {mode: 'normal'} <<< env-param

  fbHandler = (req, res) ->
    result <- opengraph.getMeta req
    res.render 'index.jade', do
      mode: 'bot'
      meta: result

  handlerMap = do
    fb: fbHandler
    def: defHandler

  patternMap = do
    fb: /externalhit_uatext|prerender/
    def: /.*/


  getReqHandler = (req) ->
    return handlerMap['def'] unless req.headers['user-agent']
    console.log req.headers['user-agent']
    for k, re of patternMap
      if req.headers['user-agent'].match re
        return handlerMap[k]

  app.use require 'prerender-node' if process.env.PRERENDER_SERVICE_URL

  app.set 'views', 'app'

  app.use '/js', express.static \_public/js
  app.use '/css', express.static \_public/css
  app.use '/data', express.static \_public/data
  app.use '/fonts', express.static \_public/fonts
  app.use '/img', express.static \_public/img

  app.use (req, res) ->
    handler = getReqHandler req
    handler req, res

if process?argv?1 is /app.(js|ls)$/
  server = require \http .create-server lyserver!
  port = if process.env.NODE_ENV is \production => 80 else 3333
  server.listen port, ->
    console.log "Running on port #port"
  server

