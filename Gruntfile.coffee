module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileBare:
        options:
          bare: true
        files:
          'lib/honegger.js': ['lib/honegger-core.coffee', 'lib/honegger-content-component.coffee',
                              'lib/honegger-content-template.coffee']
          'lib/honegger-plugins.js': ['lib/plugins/*.coffee']
          'build/honegger-spec-helpers.js': ['spec/spec_helpers.coffee']
      compile:
        files:
          'build/honegger-spec.js': ['spec/*.coffee']
    jasmine:
      src: ['lib/honegger.js', 'lib/honegger-plugins.js']
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
