module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileBare:
        options:
          bare: true
        files:
          'lib/honegger.js': ['lib/**/*.coffee']
      compile:
        files:
          'spec/honegger-spec.js': ['spec/**/*.coffee']
    jasmine:
      src: 'lib/**/*.js'
      options:
        specs: 'spec/**/*.js'
        vendor: ['vendor/jquery-2.0.3.min.js', 'vendor/jquery.hotkeys.js', 'vendor/jasmine-jquery.js']
    watch:
      files: '**/*.coffee'
      tasks: ['test']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'test', ['coffee', 'jasmine']
  grunt.registerTask 'default', ['test']
