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
