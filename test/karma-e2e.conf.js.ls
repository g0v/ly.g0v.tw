module.exports = (karma) ->
  karma.set do
    basePath: "../"
    frameworks: ["ng-scenario"]
    files: [
      * "test/e2e/**/*.ls"
    ]
    exclude: []
    reporters: ["progress"]
    port: 9876
    runnerPort: 9100
    colors: true
    logLevel: karma.LOG_INFO
    urlRoot: '/__karma/'
    autoWatch: true
    browsers: ["Chrome", "PhantomJS"]
    captureTimeout: 60000
    plugins: <[karma-ng-scenario karma-live-preprocessor karma-chrome-launcher karma-phantomjs-launcher]>
    preprocessors: do
        '**/*.ls': ['live']
    proxies: do
      '/': 'http://localhost:3333/'
    singleRun: false

