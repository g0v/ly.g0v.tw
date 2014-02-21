exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  modules:
    wrapper: (path, data) ->
      if [_, name]? = path.match /([^/\\]+)\.jsenv/
        """
(function() {
  var module = {};
  #{data};
  if (!window.global)
    window.global = {};
  window.global['#name'] = module.exports;
}).call(this);\n\n
        """
      else
        """
  #{data}
  ;\n\n
        """
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/

  # Enable or disable minifying of result js / css files.
  # minify: true
  plugins:
    jade_angular:
#      single_file_name: \app.templates.js
      locals:
        googleAnalytics: 'UA-41326468-1'
