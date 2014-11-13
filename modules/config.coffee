fs = require('fs')

configPath = "#{global.appDataPath}/poi-config.json"

exports.config = defaultConfig =
  version: '0.0.1-d'
  proxy:
    useShadowsocks:   true
    shadowsocks:
      serverIp:       '106.186.30.188'
      serverPort:     3388
      localPort:      8788
      method:         'aes-256-cfb'
      password:       'MagicaSocks'
      timeout:        600000
    useHttpProxy:     false
    httpProxy:
      httpProxyIp:      '127.0.0.1'
      httpProxyPort:    8099
    useSocksProxy:    false
    socksProxy:
      socksProxyIp:     '127.0.0.1'
      socksProxyPort:   8099
  poi:
    listenPort:       8787
  cache:
    useStorage:       true
    useCache:         false
  antiCat:
    retryDelay:       10000
    retryTime:        500

saveDefaultConfig = ->
  fs.writeFileSync configPath, JSON.stringify defaultConfig, null, 2

saveConfig = ->
  fs.writeFileSync configPath, JSON.stringify exports.config, null, 2

exports.loadConfig = ->
  try
    exports.config = JSON.parse fs.readFileSync configPath
    if exports.config.version != defaultConfig.version
      throw "version error"
  catch err
    exports.config = defaultConfig
    saveDefaultConfig()

exports.updateConfig = (conf) ->
  exports.config = conf
  try
    saveConfig()
  catch
    return false
  return true
