'use strict'

exports.config =
  name: 'Taihen Games'
  version: '0.1.0'
  src_path:
    list: ['jade','stylus','png']
    png: 'app/**/*.png'
    jade: 'app/**/*.jade'
    stylus: 'app/**/*.styl'
  build_path: 'build'
  release_path: 'release'
  electric:
    rootfile: 'main.js'
    src_path: 'desktop'
    version: '0.37.5'
  web:
    release_dir: 'web'
  mobile:
    cordova:
      path: './cordova'
      config: './mobile/config.xml'
      cmd:
        create: ['create','cordova']
        platforms: ['platform','add','android']
        build: ['build','android']
