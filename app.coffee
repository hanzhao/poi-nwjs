global.$ = window.$
global.$$ = window.$$
require('./modules/config').loadConfig()
require('./modules/ui').initConfig()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
