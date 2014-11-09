global.$ = window.$
global.$$ = window.$$
require('./modules/config').loadConfig()
require('./modules/ui').initConfig()
require('./modules/pac').generatePAC()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
