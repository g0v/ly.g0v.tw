#!/usr/bin/env lsc -cj
name: "ly.g0v.tw"
repo: "g0v/ly.g0v.tw"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  "commonjs-require-definition": "~0.1.2"
  jquery: "~2.0.3"
  angular: "1.2.12"
  "angular-mocks": "1.2.12"
  "angular-scenario": "1.2.12"
  "angular-ui-router": "0.0.1"
  "google-diff-match-patch-js": "~1.0.0"
  cryptojslib: "3.1.2"
  "ng-grid": "https://github.com/angular-ui/ng-grid.git#9ccc29d3b76e0ce89614f6480232ea968ba0da7e"
  "angular-qrcode": "~2.0.0"
  "jquery-scrollintoview": "Arwid/jQuery.scrollIntoView"

overrides:
  "angular":
    dependencies: jquery: "*"
  "angular-mocks":
    main: "README.md"
  "angular-scenario":
    main: "README.md"
  cryptojslib:
    main: "rollups/md5.js"
  "google-diff-match-patch-js":
    main: "diff_match_patch_uncompressed.js"
  "jquery-scrollintoview":
    main: "jquery.scrollIntoView.js"
