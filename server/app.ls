require! <[express ./opengraph]>

lyserver = (app) ->
  port = if process.env.NODE_ENV is \production => 80 else 3333

  defHandler = (req, res) ->
    res.render 'index.html', do
      mode: 'normal'

  fbHandler = (req, res) ->
    result <- opengraph.getMeta req
    res.render 'index.html', do
      mode: 'bot'
      meta: result

  handlerMap = do
    fb: fbHandler
    def: defHandler

  patternMap = do
    fb: /.*www.facebook.com\/externalhit_uatext.php.*/
    def: /.*/


  getReqHandler = (req) ->
    return handlerMap['def'] unless req.headers['user-agent']
    console.log req.headers['user-agent']
    for k, re of patternMap
      if req.headers['user-agent'].match re
        return handlerMap[k]

  app.engine '.html', require('ejs').__express
  app.set 'views', '_public'

  app.use '/js', express.static \_public/js
  app.use '/css', express.static \_public/css
  app.use '/data', express.static \_public/data
  app.use '/fonts', express.static \_public/fonts
  app.use '/img', express.static \_public/img

  app.use (req, res) ->
    handler = getReqHandler req
    handler req, res

  app.listen port, ->
    console.log "Running on port #port"

app = express!
lyserver app

