'use strict'

webpack = require 'webpack'

exports.config =
  name: 'Taihen Games'
  version: '0.1.0'
  src_path:
    list: ['jade','stylus','static','scripts']
    static: 'app/**/*.png'
    jade: 'app/**/*.jade'
    stylus: 'app/**/*.styl'
    scripts: ['app/scripts/vendor.coffee','app/scripts/app.cjsx']
  webpack:
    entry:
      app: './app/scripts/app.cjsx'
      vendor: './app/scripts/vendor.coffee'
    output: filename: '[name].js'
    module:
      loaders: [
        {test: /\.coffee$/,loader: 'coffee-loader'}
        {test: /\.cjsx$/,loader: 'coffee-jsx-loader'}
      ]
    plugins: [
      new webpack.optimize.UglifyJsPlugin()
    ]
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
