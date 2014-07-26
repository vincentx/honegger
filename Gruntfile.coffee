module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileBare:
        options:
          bare: true
        files:
          'lib/honegger.js': ['lib/honegger-core.coffee', 'lib/honegger-content-component.coffee']
          'build/honegger-spec-helpers.js': ['spec/spec_helpers.coffee']
          'build/honegger-shared-spec.js': ['spec/should_*.coffee']
      compile:
        files:
          'build/honegger-spec.js': ['spec/composing_mode_plugin_spec.coffee',
                                     'spec/content_component_plugin_spec.coffee']
    jasmine:
      src: 'lib/**/*.js'
      options:
        keepRunner: true
        specs: ['build/honegger-shared-spec.js', 'build/honegger-spec.js']
        helpers: 'build/honegger-spec-helpers.js'
        vendor: ['vendor/jquery-2.0.3.min.js', 'vendor/jquery.hotkeys.js', 'vendor/jasmine-jquery.js']
    watch:
      files: '**/*.coffee'
      tasks: ['test']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'test', ['coffee', 'jasmine']
  grunt.registerTask 'default', ['test']
