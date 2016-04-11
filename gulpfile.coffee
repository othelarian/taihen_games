'use strict'

# REQUIRES ######################################

changed = require 'gulp-changed'
child_p = require 'child_process'
config = require('./config').config
del = require 'del'
elecpack = require 'electron-packager'
fs = require 'fs'
gcoffee = require 'gulp-coffee'
gjade = require 'gulp-jade'
gstylus = require 'gulp-stylus'
gulp = require 'gulp'
gutil = require 'gulp-util'
plumber = require 'gulp-plumber'
process = require 'process'
readl = require 'readline'
runSeq = require 'run-sequence'
srcmap = require 'gulp-sourcemaps'
through = require 'through2'
uglify = require 'gulp-uglify'

# GLOBAL VARIABLES ##############################

mobile =
  flag: false
  regexp: new RegExp '(var mobile = false)'
  replace: 'var mobile = true'
pack_args = null
pack_lvl = null
prod = false
rl = null
web =
  flag: false
  regexp: new RegExp '(var web = false)'
  replace: 'var web = true'

# SPECIAL PIPES & FUNCTIONS #####################

clean_package = (opt) ->
  return through.obj (file,enc,cb) ->
    data = JSON.parse file.contents.toString 'utf-8'
    delete data.devDependencies
    data.main = config.electric.rootfile
    file.contents = new Buffer JSON.stringify data
    cb null,file

jade_specify = (opt) ->
  through.obj (file,enc,cb) ->
    data = file.contents.toString 'utf-8'
    if mobile.flag then data = data.replace mobile.regexp,mobile.replace
    if web.flag then data = data.replace web.regexp,web.replace
    file.contents = new Buffer data
    cb null,file

ask_pack = ->
  pack_args =
    dir: config.build_path
    name: config.name
    out: config.release_path
    version: config.electric.version
    overwrite: true
    asar: true
  rl = readl.createInterface process.stdin,process.stdout,null
  console.log 'ELECTRON PACKAGE CREATION'
  rl.setPrompt 'target platform (linux,darwin,win32 or all) ?'
  rl.prompt()
  pack_lvl = 0
  #
  rl.on 'line',(line) ->
    if pack_lvl is 0
      switch line.trim()
        when 'linux'
          pack_args.platform = 'linux'
          pack_lvl = 1
        when 'darwin'
          pack_args.platform = 'darwin'
          pack_args.arch = 'x64'
          pack_lvl = 2
        when 'win32'
          pack_args.platform = 'win32'
          pack_lvl = 1
        when 'all'
          pack_args.all = true
          pack_lvl = 2
        else console.log 'please enter one of the possibilities'
    else if pack_lvl is 1
      switch line.trim()
        when 'ia32'
          pack_args.arch = 'ia32'
          pack_lvl = 2
        when 'x64'
          pack_args.arch = 'x64'
          pack_lvl = 2
        when 'all'
          pack_args.arch = 'all'
          pack_lvl = 2
        else console.log 'please enter one of the possibilities'
    switch pack_lvl
      when 0
        rl.setPrompt 'target platform (linux,darwin,win32 or all) ? '
        rl.prompt()
      when 1
        rl.setPrompt 'target architecture (ia32,x64,all) ? '
        rl.prompt()
      when 2 then rl.close()
  rl.on 'close', ->
    console.log 'CREATE PACKAGE ...'
    elecpack pack_args,(err,appPath) -> if err then err else 'PACKAGE CREATION SUCCEED'

# DEFAULT TASK ##################################

gulp.task 'default', ->
  gutil.log ''
  gutil.log '### TAIHEN GAMES - TASKS COMMANDER ###'
  gutil.log ''
  gutil.log 'Tasks lists :'
  gutil.log '* clean -> clear the build directory'
  gutil.log '* watch -> for dev purpose'
  gutil.log '* test -> launch the app in desktop mod'
  gutil.log '* server -> launch http-server for test'
  gutil.log '* android -> deploy on android for test'
  gutil.log ''
  gutil.log '* mobile_build -> dev build for mobile, no run'
  gutil.log '* mobile_prod -> prod build for mobile, no run'
  gutil.log '* mobile_clear -> remove cordova directory'
  gutil.log '* mobile_pack -> ...'
  gutil.log ''
  gutil.log '* web_build -> dev build for web app, no run'
  gutil.log '* web_prod -> prod build for web app, no run'
  gutil.log '* web_pack -> create repository in release directory, ready to use'
  gutil.log ''
  gutil.log '* desktop_build -> dev build for desktop, no run'
  gutil.log '* desktop_prod -> prod build for desktop, no run'
  gutil.log '* desktop_pack -> create distributable desktop app'
  gutil.log ''

# COMMON TASKS ##################################

gulp.task 'prod', -> prod = true
gulp.task 'clean', -> del config.build_path+'/**/*'
gulp.task 'parse', config.src_path.list

gulp.task 'copy', ->
  #
  gutil.log gutil.colors.red 'NOT READY YET !!'
  #
  #

gulp.task 'jade', ->
  gulp
    .src config.src_path.jade
    .pipe changed config.build_path
    .pipe unless prod then plumber() else gutil.noop()
    .pipe jade_specify()
    .pipe gjade()
    .pipe gulp.dest config.build_path

gulp.task 'stylus', ->
  gulp
    .src config.src_path.stylus
    .pipe changed config.build_path
    .pipe unless prod then plumber() else gutil.noop()
    .pipe unless prod then srcmap.init() else gutil.noop()
    .pipe gstylus compress: true
    .pipe unless prod then srcmap.write() else gutil.noop()
    .pipe gulp.dest  config.build_path

# TEST TASKS ####################################

gulp.task 'watch',['clean','parse'], ->
  for pth in config.src_path.list then gulp.watch config.src_path[pth],[pth]

gulp.task 'test', ->
  process.chdir config.build_path
  child_p.execFileSync 'electron',['.'],stdio: [0,1,2]

gulp.task 'server', ->
  process.chdir config.build_path
  child_p.execFileSync 'http-server',[],stdio: [0,1,2]

gulp.task 'android', ->
  process.chdir config.mobile.cordova.path
  child_p.execFileSync 'cordova',['run','android'],stdio: [0,1,2]

# ANDROID TASKS #################################

gulp.task 'mobile', -> mobile.flag = true
gulp.task 'mobile_build', -> runSeq 'clean','mobile','parse','cordova'
gulp.task 'mobile_prod',['prod','mobile_build']
gulp.task 'cordova', -> runSeq 'cordova_dir','cordova_config','cordova_copy','cordova_build'

gulp.task 'mobile_clear', ->
  del config.mobile.cordova.path+'/**/*'
  del config.mobile.cordova.path

gulp.task 'mobile_pack',['mobile_prod'], ->
  #
  # TODO : aucune utilité dans ce script
  #
  on
  #

gulp.task 'cordova_dir', ->
  try
    fs.statSync config.mobile.cordova.path
  catch err
    child_p.execFileSync 'cordova',config.mobile.cordova.cmd.create,stdio: [0,1,2]
    process.chdir config.mobile.cordova.path
    child_p.execFileSync 'cordova',config.mobile.cordova.cmd.platforms,stdio: [0,1,2]
    del 'www/**/*'

gulp.task 'cordova_config',['cordova_dir'], ->
  gulp
    .src config.mobile.cordova.config
    .pipe gulp.dest config.mobile.cordova.path

gulp.task 'cordova_copy',['cordova_dir'], ->
  gulp
    .src config.build_path+'/**/*'
    .pipe gulp.dest config.mobile.cordova.path+'/www'

gulp.task 'cordova_build',['cordova_dir'], ->
  #
  # TODO : add release case
  #
  process.chdir config.mobile.cordova.path
  child_p.execFileSync 'cordova',config.mobile.cordova.cmd.build,stdio: [0,1,2]

# WEB TASKS #####################################

gulp.task 'web', -> web.flag = true
gulp.task 'web_build',['clean','web','parse']
gulp.task 'web_prod',['prod','web_build']

gulp.task 'web_pack',['web_prod'], ->
  gulp
    .src config.build_path+'/**/*'
    .pipe gulp.dest config.release_path+'/'+config.web.release_dir

# ELECTRON TASKS ################################

gulp.task 'desktop', -> on
gulp.task 'desktop_build',['clean','desktop','parse','electrify','create_json']
gulp.task 'desktop_prod',['prod','desktop_build']
gulp.task 'desktop_pack',['desktop_prod'], -> ask_pack()

gulp.task 'electrify', ->
  gulp
    .src config.electric.src_path+'/**/*.coffee'
    .pipe changed config.build_path
    .pipe if not prod then plumber() else gutil.noop()
    .pipe if not prod then srcmap.init() else gutil.noop()
    .pipe gcoffee bare: true
    .pipe uglify()
    .pipe if not prod then srcmap.write() else gutil.noop()
    .pipe gulp.dest config.build_path

gulp.task 'create_json', ->
  gulp
    .src './package.json'
    .pipe clean_package()
    .pipe gulp.dest config.build_path
