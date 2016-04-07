'use strict'

# REQUIRES ######################################

electron = require 'electron'

# GLOBAL VARIABLES ##############################

app = electron.app
BrowWin = electron.BrowserWindow
height = 600
width = 800

# APP ###########################################

app.on 'window-all-closed', -> app.quit()

app.on 'ready', ->
  mainwin = new BrowWin width: width,height: height
  mainwin.loadURL 'file://'+__dirname+'/index.html'
  mainwin.setMenuBarVisibility false
  mainwin.setMinimumSize width,height
  #
  mainwin.webContents.openDevTools()
  #
