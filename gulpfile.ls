require! <[tiny-lr]>
require! <[gulp gulp-util gulp-stylus gulp-mocha gulp-karma gulp-livereload]>
gutil = gulp-util
{protractor, webdriver_update} = require \gulp-protractor

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

gulp.task \webdriver_update, webdriver_update

gulp.task \protractor <[webdriver_update httpServer]> ->
  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor configFile: "./test/protractor.conf.ls"
    .on \error ->
      throw it

gulp.task 'test:e2e' <[protractor]> ->
  httpServer.close!

gulp.task 'protractor:sauce' <[webdriver_update build httpServer]> ->
  args =
    '--selenium-address'
    ''
    '--sauce-user'
    process.env.SAUCE_USERNAME
    '--sauce-key'
    process.env.SAUCE_ACCESS_KEY
    '--capabilities.build'
    process.env.TRAVIS_BUILD_NUMBER
  if process.env.TRAVIS_JOB_NUMBER
    #args['capabilities.tunnel-identifier'] = that
    args.push '--capabilities.tunnel-identifier'
    args.push that

  gulp.src ["./test/e2e/app/*.ls"]
    .pipe protractor do
      configFile: "./test/protractor.conf.ls"
      args: args
    .on \error ->
      throw it

gulp.task 'test:sauce' <[protractor:sauce]> ->
  httpServer.close!

gulp.task 'build' <[template bower assets js:vendor js:app css]>

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

gulp.task 'dev' <[httpServer template assets js:vendor js:app css]> ->
  #gulp.start 'test:karma'
  #gulp.start 'test:util'
  LIVERELOADPORT = 35729
  livereload-server.listen LIVERELOADPORT, ->
    return gutil.log it if it
  gulp.watch ['app/partials/**/*.jade', 'app/diff/*.jade', 'app/spy/*.jade'] <[template]>
  gulp.watch ['app/**/*.ls', 'app/**/*.jsenv'] <[js:app]>
  gulp.watch 'app/assets/**' <[assets]>
  gulp.watch 'app/**/*.styl' <[css]>

require! <[gulp-angular-templatecache gulp-jade]>
gulp.task 'template' ->
  gulp.src ['app/partials/**/*.jade', 'app/diff/*.jade', 'app/spy/*.jade']
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache 'app.templates.js' do
      base: process.cwd()
      filename: 'app.templates.js'
      module: 'app.templates'
      standalone: true
    .pipe gulp.dest '_public/js'
    .pipe livereload!

require! <[gulp-bower gulp-bower-files gulp-filter gulp-uglify gulp-cssmin]>
require! <[gulp-concat gulp-json-editor gulp-commonjs gulp-insert]>

gulp.task 'bower' ->
  gulp-bower!

gulp.task 'js:app' ->
  env = gulp.src 'app/**/*.jsenv'
    .pipe gulp-json-editor (json) ->
      for key of json when process.env[key]?
        json[key] = that
      json
    .pipe gulp-insert.prepend 'module.exports = '
    .pipe gulp-commonjs!

  app = gulp.src 'app/**/*.ls'
    .pipe livescript({+bare}).on 'error', gutil.log

  s = streamqueue { +objectMode }
    .done env, app
    .pipe gulp-concat 'app.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s.pipe gulp.dest '_public/js'
    .pipe livereload!

gulp.task 'js:vendor' <[bower]> ->
  bower = gulp-bower-files!
    .pipe gulp-filter -> it.path is /\.js$/

  s = streamqueue { +objectMode }
    .done bower, gulp.src 'vendor/scripts/*.js'
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

  s = streamqueue { +objectMode }
    .done bower, styl, gulp.src 'app/styles/**/*.css'
    .pipe gulp-concat 'app.css'
  s .= pipe gulp-cssmin! if gutil.env.env is \production
  s .pipe gulp.dest './_public/css'
    .pipe livereload!

gulp.task 'assets' ->
  gulp.src 'app/assets/**'
    .pipe gulp.dest '_public'

gulp.task 'ly-diff' <[ly-diff:js ly-diff:css]>

require! <[streamqueue gulp-concat]>
gulp.task 'ly-diff:js' ->
  js = gulp.src <[app/utils/diff.ls app/diff.ls]>
    .pipe livescript({+bare}).on 'error', gutil.log
  templates = gulp.src 'app/diff/diff.jade'
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache do
      base: process.cwd()
      filename: 'app.templates.js'
      module: 'ly.diff'

  streamqueue { +objectMode }
    .done js, templates
    .pipe gulp-concat 'ly-diff.js'
    .pipe gulp.dest '_public/js'

gulp.task 'ly-diff:css' ->
  gulp.src './app/styles/ly-diff.styl'
  .pipe gulp-stylus use: <[nib]>
  .pipe gulp.dest './_public/css'
