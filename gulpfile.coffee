'use strict'

# REQUIRES ######################################

config = require('./config').config
changed = require 'gulp-changed'
gjade = require 'gulp-jade'
gstylus = require 'gulp-stylus'
gulp = require 'gulp'
gutil = require 'gulp-util'
plumber = require 'gulp-plumber'
srcmap = require 'gulp-sourcemaps'
through = require 'through2'

# GLOBAL VARIABLES ##############################

mobile =
  flag: false
  regexp: new RegExp '(var mobile = false)'
  replace: 'var mobile = true'
parse_lst = ['jade','stylus']
prod = false
rl = null
web =
  flag: false
  regexp: new RegExp '(var web = false)'
  replace: 'var web = true'

# SPECIAL PIPES #################################

jade_specify = (opt) ->
  through.obj (file,enc,cb) ->
    data = file.contents.toString 'utf-8'
    #
    #data = data.replace mobile_regexp,'var mobile = true'
    #
    #
    file.contents = new Buffer data
    cb null,file

# DEFAULT TASK ##################################

gulp.task 'default', ->
  gutil.log ''
  gutil.log '### TAIHEN GAMES - TASKS COMMANDER ###'
  gutil.log ''
  gutil.log 'Tasks lists :'
  gutil.log '* clean -> clear the build directory'
  gutil.log '* build -> construct the front part'
  gutil.log '* watch -> pretty obvious'
  gutil.log '* test -> launch the app in test mode'
  gutil.log ''
  gutil.log '* mobile_build -> dev build for mobile, no run'
  gutil.log '* mobile_prod -> prod build for mobile, no run'
  #
  gutil.log ''
  gutil.log '* web_dev -> dev build for web app, no run'
  gutil.log '* web_prod -> prod build for web app, no run'
  #
  gutil.log ''

# COMMON TASKS ##################################

gulp.task 'prod', -> prod = true
gulp.task 'clean', -> del config.build_path
gulp.task 'build',parse_lst

gulp.task 'copy', ->
  #
  gutil.log gutil.colors.red 'NOT READY YET !!'
  #
  #

gulp.task 'jade', ->
  gulp
    .src config.src_path+'/**/*.jade'
    .pipe changed config.build_path
    .pipe if not prod then plumber() else gutil.noop()
    .pipe jade_specify()
    .pipe gjade()
    .pipe gulp.dest config.build_path

gulp.task 'stylus', ->
  gulp
    .src config.src_path+'/**/*.styl'
    .pipe changed config.build_path
    .pipe if not prod then plumber() else gutil.noop()
    .pipe if not prod then srcmap.init() else gutil.noop()
    .pipe gstylus compress: true
    .pipe if not prod then srcmap.write() else gutil.noop()
    .pipe gulp.dest  config.build_path

# TEST TASKS ####################################

gulp.task 'test', ->
  #
  gutil.log 'test task'
  gutil.log gutil.colors.red 'NOT READY YET !!'
  #
  #

# ANDROID TASKS #################################

gulp.task 'mobile', -> mobile.flag = true
gulp.task 'mobile_build',['mobile','build']

gulp.task 'mobile_prod', ->
  #
  #
  on
  #

# WEB TASKS #####################################

gulp.task 'web', -> web.flag = true
gulp.task 'web_build',['web','build']
gulp.task 'web_prod',['web','prod','build']

# ELECTRON TASKS ################################
