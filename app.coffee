fs = require('fs')
gui = window.require('nw.gui')
if process.platform == 'darwin'
  # OSX: /Users/$user/Library/Application Support/poi
  global.appDataPath = "#{fs.realpathSync(gui.App.dataPath + '/..')}/poi"
else
  # Win or Linux:
  global.appDataPath = fs.realpathSync(process.execPath + '/..')
global.$ = window.$
global.$$ = window.$$
global.Notification = window.Notification
global.Notification.requestPermission()
require('./modules/config').loadConfig()
ui = require('./modules/ui')
ui.initConfig()
ui.api_start2_loadDefault()
require('./modules/pac').generatePAC()
require('./modules/cache').initCache()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
