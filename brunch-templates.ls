exports.config =
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/null.js': /^null/

    stylesheets:
      joinTo:
        'css/null.css': /^null/

    templates:
      joinTo:
        'js/templates.js': /^app\/view.*\.jade$/

  # Enable or disable minifying of result js / css files.
  # minify: true
  plugins:
    jade:
      pretty: yes
    static_jade:
      extension: '.none'
