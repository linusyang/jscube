module.exports = function(grunt) {

  var config = {
    clean: [
        'index.html',
        'ppt.js',
        'ppt.css',
        'fonts/'
      ],
    jade: {
      src: {
        files: [{
          expand: true,
          cwd: 'src/',
          src: '**/*.jade',
          dest: './',
          ext: '.html'
        }]
      }
    },
    stylus: {
      src: {
        files: [{
          expand: true,
          cwd: 'src/',
          src: '**/*.styl',
          dest: './',
          ext: '.css'
        }],
        options: {
          compress: false
        }
      }
    },
    coffee: {
      src: {
        files: [{
          expand: true,
          cwd: 'src/',
          src: '**/*.coffee',
          dest: './',
          ext: '.js'
        }]
      }
    },
    copy: {
      src: {
        files: [{
          expand: true,
          cwd: 'src/img/',
          src: '**/*',
          dest: './img/'
        },{
          expand: true,
          cwd: 'src/fonts/',
          src: '**/*',
          dest: './fonts/'
        },{
          expand: true,
          cwd: 'src/',
          src: 'ppt.js',
          dest: './'
        }]
      }
    },
    concurrent: {
      compile: {
        tasks: [
          'jade',
          'stylus',
          'coffee',
          'copy'
        ],
        options: {
            logConcurrentOutput: false
        }
      },
    },
  };

  grunt.initConfig(config);

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-contrib-stylus');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-concurrent');

  grunt.registerTask('default', ['clean', 'concurrent:compile']);

};
