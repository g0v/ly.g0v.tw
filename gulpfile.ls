require! <[tiny-lr]>
require! <[gulp gulp-util gulp-stylus gulp-mocha gulp-karma gulp-livereload]>
gutil = gulp-util
{protractor} = require \gulp-protractor

livescript = require \gulp-livescript
livereload-server = require(\tiny-lr)!
livereload = -> gulp-livereload livereload-server

gulp.task 'server' ->
  gulp.src './server/*.ls'
    .pipe livescript({+bare}).on 'error', gutil.log
    .pipe gulp.dest './server/'

var http-server

gulp.task \httpServer <[server]> ->
  {lyserver} = require \./server/app
  app = require('express')!
  app.use require('connect-livereload')!
  # use http-server here so we can close after protractor finishes
  http-server := require \http .create-server lyserver app
  port = 3333
  http-server.listen port, ->
    console.log "Running on http://localhost:#port"

gulp.task \protractor <[httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"
    .on \error ->
      throw it

gulp.task 'test:e2e' <[protractor]> ->
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
