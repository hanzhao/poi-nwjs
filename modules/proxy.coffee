http = require('http')
socks = require('socksv5')
fs = require('fs')
url = require('url')
local = require('shadowsocks')
config = require('./config').config
Buffer = require('buffer').Buffer
processor = require('./processor')
ui = require('./ui')
util = require('./util')
cache = require('./cache')
storage = require('./storage')

exports.createShadowsocksServer = ->
  return unless config.proxy.useShadowsocks
  local.createServer config.proxy.shadowsocks.serverIp, config.proxy.shadowsocks.serverPort, config.proxy.shadowsocks.localPort, config.proxy.shadowsocks.password, config.proxy.shadowsocks.method, config.proxy.shadowsocks.timeout, '127.0.0.1'
  # if config.proxy.shadowsocks.serverIp == '106.186.30.188'
  #   ui.showModal '注意', '默认的代理设置仅供测试和日常使用，不保证实际使用体验，请尽量使用其他专业VPN！'
  util.log "Shadowsocks @ 127.0.0.1:#{config.proxy.shadowsocks.localPort}"

exports.createServer = ->
  server = http.createServer (req, res) ->
    parsed = url.parse req.url
    options = getOptions req, parsed
    # Load File From Cache
    getCache = false
    if config.cache.useStorage && req.method == 'GET' && util.isCacheUrl req.url
      getCache = storage.loadStorageFile req, res
    return if getCache
    # Local Cache?
    # if config.cache.useCache && util.isCacheUrl req.url
    #   await cache.loadCacheFile req, res, defer getCache
    # return if getCache
    # Post Data
    postData = ''
    req.setEncoding 'utf8'
    req.addListener 'data', (chunk) ->
      postData += chunk
    req.addListener 'end', ->
      options.postData = req.postData = postData
      sendHttpRequest options, 0, (result) ->
        if result.err
          res.writeHead 500,
            'Content-Type': 'text/html'
          res.write '<!DOCTYPE html><html><body><h1>Network Error</h1></body></html>'
          res.end()
        else
          buffers = []
          result.on 'data', (chunk) ->
            buffers.push chunk
          result.on 'end', ->
            data = Buffer.concat buffers
            result.removeAllListeners 'data'
            result.removeAllListeners 'end'
            res.writeHead result.statusCode, result.headers
            res.write data
            res.end()
            processor.processData req, data if req.url.indexOf('/kcsapi') != -1
            storage.saveStorageFile req, data if config.cache.useStorage && req.method == 'GET' && result.statusCode == 200 && util.isCacheUrl req.url
            # cache.saveCacheFile req, data if req.url.indexOf('/kcs/') != -1
  server.listen config.poi.listenPort
  util.log "Poi Proxy @ 127.0.0.1:#{config.poi.listenPort}"

getOptions = (req, parsed) ->
  options = null
  if config.proxy.useShadowsocks
    util.log "正在使用Shadowsocks代理访问 #{req.url}"
    socksConfig =
      proxyHost:  '127.0.0.1'
      proxyPort:  config.proxy.shadowsocks.localPort
      auths:      [ socks.auth.None() ]
    options =
      host:       parsed.host || '127.0.0.1'
      hostname:   parsed.hostname || '127.0.0.1'
      port:       parsed.port || 80
      method:     req.method
      path:       parsed.path || '/'
      headers:    req.headers
      agent:      new socks.HttpAgent(socksConfig)
  else if config.proxy.useSocksProxy
    util.log "正在使用Socks5代理访问 #{req.url}"
    socksConfig =
      proxyHost:  config.proxy.socksProxy.socksProxyIp
      proxyPort:  config.proxy.socksProxy.socksProxyPort
      auths:      [ socks.auth.None() ]
    options =
      host:       parsed.host || '127.0.0.1'
      hostname:   parsed.hostname || '127.0.0.1'
      port:       parsed.port || 80
      method:     req.method
      path:       parsed.path || '/'
      headers:    req.headers
      agent:      new socks.HttpAgent(socksConfig)
  else if config.proxy.useHttpProxy
    util.log "正在使用HTTP代理访问 #{req.url}"
    options =
      host:     config.proxy.httpProxy.httpProxyIP
      port:     config.proxy.httpProxy.httpProxyPort
      method:   req.method
      path:     req.url
      headers:  req.headers
  else
    util.log "正在使用全局默认连接方式访问 #{req.url}"
    options =
      host: parsed.host || '127.0.0.1'
      hostname: parsed.hostname || '127.0.0.1'
      port: parsed.port || 80
      method: req.method || 'GET'
      path: parsed.path || '/'
      headers: req.headers
  return options

sendHttpRequest = (options, counter, callback) ->
  request = http.request options, (result) ->
    if (options.path.indexOf('/kcsapi/') != -1 || options.path.indexOf('/kcs/') != -1) && (result.statusCode == 500 || result.statusCode == 502 || result.statusCode == 503)
      util.log "HTTP #{result.statusCode} 正在进行第#{counter}次重试"
      if counter != config.antiCat.retryTime
        ui.addAntiCatCounter()
        setTimeout ->
          sendHttpRequest(options, counter + 1, callback)
        , config.antiCat.retryDelay
      else
        callback {err: true}
    else
      callback result
  if options.method == "POST" && options.postData
    request.write options.postData
  request.on 'error', (e) ->
    return unless options.path.indexOf('/kcsapi/') != -1 || options.path.indexOf('/kcs/') != -1
    util.log "错误 #{e} 正在进行第#{counter}次重试"
    if counter != config.antiCat.retryTime
      ui.addAntiCatCounter()
      setTimeout ->
        sendHttpRequest(options, counter + 1, callback)
      , config.antiCat.retryDelay
    else
      callback {err: true}
  request.end()
