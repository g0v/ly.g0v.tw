#!/usr/bin/env lsc -bc
require! child_process
require! async
require! <[gulp gulp-exec]>
gutil = require 'gulp-util'
{protractor} = require \gulp-protractor

livescript = require \gulp-livescript

gulp.task 'server' ->
  gulp.src './server/*.ls'
    .pipe livescript({+bare}).on 'error', gutil.log
    .pipe gulp.dest './server/'

var http-server

gulp.task \httpServer <[server build]> ->
  {lyserver} = require \./server/app
  http-server := require \http .create-server lyserver!
  port = 3333
  http-server.listen port, ->
    console.log "Running on port #port"

gulp.task \protractor <[httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"

gulp.task 'test:e2e' <[protractor]> ->
  httpServer.close!

gulp.task 'protractor:sauce' <[httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor do
      configFile: "./test/protractor.conf.ls"
      args: do
        seleniumAddress: ''
        sauceUser: process.env.SAUCE_USERNAME
        sauceKey: process.env.SAUCE_ACCESS_KEY
        'capabilities.tunnel-identifier': process.env.TRAVIS_JOB_NUMBER
        'capabilities.build': process.env.TRAVIS_BUILD_NUMBER

gulp.task 'test:sauce' <[protractor:sauce]> ->
  httpServer.close!

gulp.task 'build' ->
  gulp.src 'package.json'
    .pipe gulp-exec 'bower i && ./node_modules/.bin/brunch b -P'

gulp.task 'test:unit' <[build]> ->
  gulp.start 'test:karma'
  gulp.start 'test:util'

gulp.task 'test:karma' ->
  gulp.src 'package.json'
    .pipe gulp-exec './node_modules/karma/bin/karma start --browsers PhantomJS --single-run true test/karma.conf.ls'
    .on \error ->
      throw it

gulp.task 'test:util' ->
  gulp.src 'package.json'
    .pipe gulp-exec './node_modules/.bin/mocha --compilers ls:LiveScript test/unit/util'
    .on \error ->
      throw it
