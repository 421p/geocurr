module.exports = function(grunt) {
    
  
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        uglify: {
            build: {
                src: 'js/build/prod.js',
                dest: 'js/build/prod.min.js'
            }
        },
        
        cssmin: {
          options: {
            shorthandCompacting: false,
            roundingPrecision: -1
          },
          target: {
            files: {
              'css/build/prod.min.css': ['css/*.css']
            }
          }
        },
        
        htmlmin: {                                     // Task
            dist: {                                      // Target
              options: {                                 // Target options
                removeComments: true,
                collapseWhitespace: true
              },
              files: {                                   // Dictionary of files
                'index.html': 'src/template.html'     // 'destination': 'source'
              }
            }
          },
          
          coffeescript_concat: {
            compile: {
              options: {
                includeFolders: [
                  'coffee'
                ]
              },
              files: {
                'coffee/build/prod.coffee': [
                  'coffee/gc_settings.coffee',
                  'coffee/gc_before.coffee',
                  'coffee/gc.coffee',
                  'coffee/class/*.coffee'
                ]
              }
            }
          },
          
          coffee: {
            compile: {
              files: {
                'js/build/prod.js': 'coffee/build/prod.coffee', // 1:1 compile
              }
            }
          },
          
          watch: {
            scripts: {
                files: ['coffee/*.coffee', 'coffee/class/*.coffee'],
                tasks: ['coffeescript_concat', 'coffee', 'uglify'],
                options: {
                    spawn: false,
                },
            },
            css: {
                files: ['css/*.css'],
                tasks: ['cssmin'],
                options: {
                    spawn: false,
                },
            },
            html: {
                files: ['src/*.html'],
                tasks: ['htmlmin'],
                options: {
                    spawn: false,
                },
            }
            
        }

    });

    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-htmlmin');
    grunt.loadNpmTasks('grunt-coffeescript-concat');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    
    grunt.registerTask('default', ['coffeescript_concat', 'coffee', 'uglify', 'cssmin', 'htmlmin']);

};