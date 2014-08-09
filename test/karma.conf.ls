module.exports = (karma) ->
  karma.set do
    basePath: "../"
    frameworks: ["mocha", "chai"]
    files:
      * "_public/js/vendor.js"
      * "_public/js/app.templates.js"
      * "_public/js/app.js"
      * "bower_components/angular-mocks/angular-mocks.js"
      * "test/unit/**/*.spec.ls"
      * pattern: 'test/unit/fixtures/**/*.json'
        watched: true
        served: true
        included: true
    exclude: []
    reporters: ["progress"]
    port: 9876
    runnerPort: 9100
    colors: true
    logLevel: karma.LOG_INFO
    autoWatch: true
    browsers: ["Chrome"]
    captureTimeout: 60000
    #plugins: ["karma-jasmine", "karma-live-preprocessor", "karma-chrome-launcher"]
    preprocessors: {
        '**/*.ls': ['live']
        './test/unit/fixtures/**/*.json': ['json_fixtures']
    }
    singleRun: false

