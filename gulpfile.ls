#!/usr/bin/env lsc -bc
require! <[child_process async tiny-lr]>
require! <[gulp gulp-stylus gulp-mocha gulp-karma gulp-livereload]>
gutil = require 'gulp-util'
{protractor, webdriver} = require \gulp-protractor

livescript = require \gulp-livescript
livereload-server = tiny-lr!
livereload = -> gulp-livereload livereload-server

gulp.task 'server' ->
  gulp.src './server/*.ls'
    .pipe livescript({+bare}).on 'error', gutil.log
    .pipe gulp.dest './server/'

const webdriver-path = './node_modules/.bin/webdriver-manager'

var webdriver-process, standalone-selenium-pid, http-server

webdriver-update = (cb) ->
  gutil.log "updating webdriver"
  child_process.spawn webdriver-path, <[update]>
    .once \close ->
      gutil.log "webdriver-update complete"
      cb!

webdriver-start = (cb) ->
  webdriver-process := child_process.spawn webdriver-path, <[start]>, stdio: [\ignore, \pipe, \ignore]
  webdriver-process.once \close ->
    gutil.log "webdriver-start complete"

  <- webdriver-process.stdout.on \data
  # webdriver won't die if selenium still running
  # so we have to kill selenium directly after protractor finish
  if it.toString! is /seleniumProcess.pid: (\d+)/
    standalone-selenium-pid := that.1
    gutil.log "Selenium Process ID: #{that.1}"
  # Wait server ready, hacky
  if it.toString! is /Started org.openqa.jetty.jetty.Server/
    webdriver-process.unref!
    gutil.log 'webdriver up'
    cb!

webdriver = (cb) ->
  async.series [webdriver-update, webdriver-start], cb

gulp.task \webdriver, webdriver

gulp.task \httpServer <[server]> ->
  {lyserver} = require \./server/app
  app = require('express')!
  app.use require('connect-livereload')!
  lyserver app
  port = 3333
  app.listen port, ->
    console.log "Running on http://localhost:#port"

gulp.task \protractor <[webdriver build httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"
    .on \error ->
      throw it

gulp.task 'test:e2e' <[protractor]> ->
  gutil.log "Kill Selenium (#{standalone-selenium-pid})"
  process.kill standalone-selenium-pid
  httpServer.close!

gulp.task 'protractor:sauce' <[build httpServer]> ->
  args =
    seleniumAddress: ''
    sauceUser: process.env.SAUCE_USERNAME
    sauceKey: process.env.SAUCE_ACCESS_KEY
    'capabilities.build': process.env.TRAVIS_BUILD_NUMBER
  if process.env.TRAVIS_JOB_NUMBER
    args['capabilities.tunnel-identifier'] = that

  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor do
      configFile: "./test/protractor.conf.ls"
      args: args
    .on \error ->
      throw it

gulp.task 'test:sauce' <[protractor:sauce]> ->
  httpServer.close!

gulp.task 'build' <[template bower js:vendor css]> (done) ->
  options = if \production is gutil.env.env => {+production} else {}
  require \brunch .build options, -> done!

gulp.task 'test:unit' <[build]> ->
  gulp.start 'test:karma'
  gulp.start 'test:util'

gulp.task 'test:karma' ->
  gulp.src [
    * "_public/js/vendor.js"
    * "_public/js/app.templates.js"
    * "_public/js/app.js"
    * "bower_components/angular-mocks/angular-mocks.js"
    * "test/unit/**/*.spec.ls"
  ]
  .pipe gulp-karma do
    config-file: 'test/karma.conf.ls'
    action: 'run'
    browsers: <[PhantomJS]>
  .on \error ->
    throw it

gulp.task 'test:util' ->
  gulp.src 'test/unit/util/**/*.ls'
    .pipe gulp-mocha compilers: 'ls:LiveScript'

gulp.task 'dev' <[httpServer template js:vendor css]> ->
  require \brunch .watch {}, ->
    gulp.start 'test:karma'
    gulp.start 'test:util'
  LIVERELOADPORT = 35729
  livereload-server.listen LIVERELOADPORT, ->
    console.log \listening
    return gutil.log it if it
  gulp.watch 'app/partials/**/*.jade' <[template]>
  gulp.watch 'app/**/*.styl' <[css]>

require! <[gulp-angular-templatecache gulp-jade]>
gulp.task 'template' ->
  gulp.src 'app/partials/**/*.jade'
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache 'app.templates.js' do
      base: process.cwd()
      filename: 'app.templates.js'
      module: 'app.templates'
      standalone: true
    .pipe gulp.dest '_public/js'
    .pipe livereload!

require! <[gulp-bower gulp-bower-files gulp-filter gulp-uglify gulp-cssmin]>
require! <[event-stream gulp-concat]>

gulp.task 'bower' ->
  gulp-bower!

gulp.task 'js:vendor' <[bower]> ->
  bower = gulp-bower-files!
    .pipe gulp-filter -> it.path is /\.js$/

  s = event-stream.merge bower, gulp.src 'vendor/scripts/**/*.js'
    .pipe gulp-concat 'vendor.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s .pipe gulp.dest '_public/js'
    .pipe livereload!

gulp.task 'css' <[bower]> ->
  bower = gulp-bower-files!
    .pipe gulp-filter -> it.path is /\.css$/

  styl = gulp.src './app/styles/**/*.styl'
    .pipe gulp-filter -> it.path isnt /\/_[^/]+\.styl$/
    .pipe gulp-stylus use: <[nib]>

  s = event-stream.merge bower, styl, gulp.src 'app/styles/**/*.css'
    .pipe gulp-concat 'app.css'
  s .= pipe gulp-cssmin! if gutil.env.env is \production
  s .pipe gulp.dest './_public/css'
    .pipe livereload!
