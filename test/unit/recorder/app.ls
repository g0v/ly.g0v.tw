require! 'express'
require! 'body-parser'
require! 'fs'
require! 'mkdirp'
require! 'colors'
{js_beautify} = require 'js-beautify'

mkdirp_for_record = (path) ->
  parts = path.split '/'
  base_parts = parts.slice 0, parts.length - 1
  base = base_parts.join '/'
  mkdirp.sync base

app = express!
app.use body-parser.urlencoded extended: true

# API: POST /record
#   path: where_to_save
#   json: json_to_save
#
# Example:
#  $.ajax do
#    type: 'POST'
#    url: 'http://localhost:9877/record'
#    data:
#      path: "test/unit/fixtures/snapshots/xxx/xxx.json"
#      json: JSON.stringigy foo: \bar
#    data-type: 'text'
app.post '/record' (req, res, next) ->
  path = req.body.path
  mkdirp_for_record path
  fs.write-file path, js_beautify req.body.json
  console.log "Recorded as #{path.bold.green} !".bold.white
  res.send 'Recorded !'
server = app.listen 9877, ->
  port = server.address!.port
  console.log "Unit test recorder server listen on port #port"
