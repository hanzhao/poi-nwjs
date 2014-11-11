global.$ = window.$
global.$$ = window.$$
global.Notification = window.Notification
global.Notification.requestPermission()
require('./modules/config').loadConfig()
require('./modules/ui').initConfig()
require('./modules/pac').generatePAC()

gui = window.nwDispatcher.requireNwGui()
fs = require('fs')
# OSX: /Users/$user/Library/Application Support/poi
global.AppDataPath = fs.realpathSync(gui.App.dataPath + '/..') + '/poi' if process.platform == 'darwin'
# Win or Linux:
global.AppDataPath = fs.realpathSync(process.execPath + '/..') if process.platform != 'darwin'

proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
