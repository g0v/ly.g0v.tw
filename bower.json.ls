#!/usr/bin/env lsc -cj
name: "ly.g0v.tw"
repo: "g0v/ly.g0v.tw"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  jquery: "~2.0.3"
  moment: "~2.4.0"
  angular: "1.2.12"
  "angular-mocks": "1.2.12"
  "angular-scenario": "1.2.12"
  "angular-ui-router": "0.0.1"
  "google-diff-match-patch-js": "~1.0.0"
  cryptojslib: "3.1.2"
  "ng-grid": "~2.0.7"
  "angular-qrcode": "~2.0.0"

overrides:
  "angular":
    dependencies: jquery: "*"
  "angular-mocks":
    main: "README.md"
  "angular-scenario":
    main: "README.md"
  cryptojslib:
    main: "rollups/md5.js"
