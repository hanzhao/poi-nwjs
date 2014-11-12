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
require('./modules/ui').initConfig()
require('./modules/pac').generatePAC()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
