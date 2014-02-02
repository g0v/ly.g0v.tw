#!/usr/bin/env lsc -bc
require! child_process
require! async
require! gulp
gutil = require 'gulp-util'
{protractor, webdriver} = require \gulp-protractor
require! pushserve

const webdriver-path = './node_modules/.bin/webdriver-manager'

var webdriver-process, standalone-selenium-pid, httpServer

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

gulp.task \httpServer ->
  httpServer := pushserve port: 3333, path: './_public/'

gulp.task \protractor <[webdriver httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"

gulp.task \default, <[protractor]> ->
  gutil.log "Kill Selenium (#{standalone-selenium-pid})"
  process.kill standalone-selenium-pid
  httpServer.close!
