'use strict'

# MAIN HOVERBOARD ###############################

window.tessFun = () -> console.log 'tessFun'

# TEST FIRST DIV ################################

window.FirstDiv = React.createClass
  render: () ->
    #
    #
    <div>test react is good</div>
    #

# ROUTES ########################################

#router =

# APP ###########################################

window.app =
  initialize: () -> @bindEvents()
  bindEvents: () ->
    document.addEventListener 'load',app.launcher(),false
    if cordova?
      document.addEventListener 'backbutton',app.exitApp(),false
  exitApp: () -> navigator.app.exitApp()
  launcher: () ->
    #
    # TODO : see for localstorage
    #
    console.log document.getElementById 'mainframe'
    #
    ReactDOM.render <FirstDiv />,document.getElementById 'mainframe'
    #

app.initialize()
