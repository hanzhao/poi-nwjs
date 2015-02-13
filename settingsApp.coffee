console.log 'in settingsApp.coffee, loaded'

global.settingsWin.on 'loaded',->
  require('./modules/settingsUi').initConfig()
  require('./assets/js/settingsApp').init()
  require('./modules/pac').generatePAC()
  console.log 'loaded, 1'