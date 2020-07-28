require! 'request'
require! 'querystring'
require! 'mkdirp'
require! 'fs'
require! 'colors'
_ = require 'lodash'
{js_beautify} = require 'js-beautify'

config = APIENDPOINT: 'http://api.ly.g0v.tw/'
base = "#{config.APIENDPOINT}v0/collections/"

colorize_path = (path) ->
  parts = path.split '/'
  colors = parts_color parts.length
  parts = _.zip(parts, colors).map (parts_with_colors) ->
    [part, its_colors] = parts_with_colors
    colorize_part part, its_colors
  parts.join '/ '

parts_color = (len) ->
  colors =
    <[bold cyan]>
    <[bold green]>
    <[bold magenta]>
  [0 to len - 1].map (i) ->
    colors[i] || [\white]

colorize_part = (part, colors) ->
  colors.reduce (part, current) ->
    part[current]
  , part

write_file = (path, content) ->
  fs.exists path, (exists) ->
    if !exists
      fs.write-file path, content

get_response = (type, fullpath, path, error, res, body, cb) ->
  success = !error && res.status-code == 200
  if (success && type == \success ||
      !success && type == \error)
    content = js_beautify res.body
    write_file fullpath, content
    console.log colorize_path path
    cb JSON.parse res.body

stringify_params = (params) ->
  params_string = ''
  for k, v of params
    if params_string != ''
      params_string = '&' + params_string
    if typeof v == 'string'
      params_string = "#k=#v" + params_string
    else
      params_string = "#k=#{JSON.stringify v}" + params_string
  params_string

cassettes_path = (dir, path, params) ->
  base = "#{process.cwd!}/test/unit/fixtures/cassettes/#dir"
  mkdirp base
  fullpath = "#base/#path"
  path = "cassettes/#dir/#path"
  if params
    params = " #{stringify_params params.params}"
    fullpath += params
    path += params
  fullpath += '.json'
  [fullpath, path].map (p) ->
    p = p.replace /"/g, \་
    p.replace /,/g, \¸

wrapHttpGet = (url, fullpath, path) ->
  req = {}
  req.success = (cb) ->
    error, res, body <- request.get {url}
    res <- get_response \success, fullpath, path, error, res, body
    cb res
  req.error = (cb) ->
    error, res, body <- request.get {url}
    res <- get_response \error, fullpath, path, error, res, body
    cb res
  req

exports.get = (dir, path, params) ->
  url = "#base#path"
  if params
    url += "?#{stringify_params params.params}"
  [fullpath, path] = cassettes_path dir, path, params
  wrapHttpGet url, fullpath, path
