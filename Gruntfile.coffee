module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      options:
        sourceMap: no
      compile:
        files: [{
          'server.js': 'src/server.coffee'
        }, {
          expand: yes
          cwd: 'src/lib'
          src: [ '*.coffee' ]
          dest: 'lib'
          ext: '.js'
        }, {
          sourceMap: yes
          expand: yes
          cwd: 'src/coffee'
          src: [ '*.coffee' ]
          dest: 'dist/javascripts'
          ext: '.js'
        }]

    sass:
      options:
        style: 'compressed'
        noCache: true
        trace: true
      dist:
        files: [{
          expand: true
          cwd: 'src/sass'
          src: [ '*.sass' ]
          dest: 'dist/stylesheets'
          ext: '.css'
        }]

    watch:
      options:
        dateFormat: (time) ->
          grunt.log.writeln "The watch finished in #{time}ms at #{new Date().toLocaleTimeString()}"
      script:
        files: ['src/**/*.coffee']
        tasks: ['coffee']
      sass:
        files: ['src/sass/*.sass']
        tasks: ['sass']

  # compile
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  # server
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'build', ['coffee', 'sass']
  grunt.registerTask 'default', ['build', 'watch']
