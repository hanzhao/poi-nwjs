global.$ = window.$
require('./modules/config').loadConfig()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
