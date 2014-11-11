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

exports.createShadowsocksServer = ->
  return unless config.proxy.useShadowsocks
  local.createServer config.proxy.shadowsocks.serverIp, config.proxy.shadowsocks.serverPort, config.proxy.shadowsocks.localPort, config.proxy.shadowsocks.password, config.proxy.shadowsocks.method, config.proxy.shadowsocks.timeout, '127.0.0.1'
  console.log "Shadowsocks listening at 127.0.0.1:#{config.proxy.shadowsocks.localPort}"

exports.createServer = ->
  server = http.createServer (req, res) ->
    parsed = url.parse req.url
    options = getOptions req, parsed
    # Load File From Cache
    loadCacheSwfFile req, res, (err) ->
      if err
        # Post Data
        postData = ''
        req.setEncoding 'utf8'
        req.addListener 'data', (chunk) ->
          postData += chunk
        req.addListener 'end', ->
          options.postData = postData
          sendHttpRequest options, 0, (result) ->
            if result.err
              res.writeHead 500, {'Content-Type': 'text/html'}
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
                saveCacheSwfFile req, data if req.url.indexOf('/kcs/') != -1
  server.listen config.poi.listenPort
  console.log "Proxy listening at 127.0.0.1:#{config.poi.listenPort}"

getOptions = (req, parsed) ->
  options = null
  if config.proxy.useShadowsocks
    console.log "Get Request #{req.url} using Shadowsocks"
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
    console.log "Get Request #{req.url} using Socks Proxy"
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
    console.log "Get Request #{req.url} using HTTP Proxy"
    options =
      host:     config.proxy.httpProxy.httpProxyIP
      port:     config.proxy.httpProxy.httpProxyPort
      method:   req.method
      path:     req.url
      headers:  req.headers
  else
    console.log "Get Request #{req.url}"
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
      console.log "Code #{result.statusCode}, retried for the #{counter} time."
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
    console.log "#{e}, retried for the #{counter} time."
    if counter != config.antiCat.retryTime
      ui.addAntiCatCounter()
      setTimeout ->
        sendHttpRequest(options, counter + 1, callback)
      , config.antiCat.retryDelay
    else
      callback {err: true}
  request.end()

# Load File From Cache
loadCacheSwfFile = (req, res, callback) ->
  # These two swf files are source code files, not resource files
  # Caching these files may cause illegal logic error I guess?
  if req.url.indexOf('/kcs/Core.swf') != -1 || req.url.indexOf('/kcs/mainD2.swf') != -1
    callback true
    return
  if req.url.indexOf('/kcs/') != -1
    # Get FilePath
    filePath = url.parse(req.url).pathname.substr 1
    # Get FileSize
    fs.stat filePath, (err, stat) ->
      if !err?
        fileSize = stat.size
        # Read File
        fs.readFile filePath, (err, data) ->
          if !err
            date = new Date().toGMTString()
            console.log "Load File From Cache: #{filePath}, Size: #{fileSize}, Date: #{date}"
            res.writeHead 200, "{
                                  \"date\":\"#{date}\",
                                  \"server\":\"Apache\",
                                  \"last-modified\":\"Wed, 23 Apr 2014 05:46:42 GMT\",
                                  \"accept-ranges\":\"bytes\",
                                  \"content-length\":\"#{fileSize}\",
                                  \"cache-control\":\"max-age=2592000, public\",
                                  \"connection\":\"close\",
                                  \"content-type\":\"application/x-shockwave-flash\"
                              }"
            res.write data
            res.end()
            callback false
          else
            console.log err
            callback true
      else
        console.log err
        callback true
  else
    callback true

# Save File To Cache
saveCacheSwfFile = (req, data) ->
  return if req.url.indexOf('/kcs/Core.swf') != -1 || req.url.indexOf('/kcs/mainD2.swf') != -1
  if req.url.indexOf('/kcs/') != -1
    # Get FilePath
    filePath = url.parse(req.url).pathname.substr 1
    util.guaranteeFilePath filePath
    # Save File
    fs.writeFile filePath, data, (err) ->
      if err?
        console.log err
      else
        console.log "Save Cache File: #{filePath}" if !err
