http = require('http')
shttp = require('socks5-http-client')
fs = require('fs')
url = require('url')
local = require('shadowsocks')
config = require('./config').config
Buffer = require('buffer').Buffer
processor = require('./processor')

exports.createShadowsocksServer = ->
  return unless config.proxy.useShadowsocks
  local.createServer config.proxy.shadowsocks.serverIp, config.proxy.shadowsocks.serverPort, config.proxy.shadowsocks.localPort, config.proxy.shadowsocks.password, config.proxy.shadowsocks.method, config.proxy.shadowsocks.timeout, '127.0.0.1'
  console.log "Shadowsocks listening at 127.0.0.1:#{config.proxy.shadowsocks.localPort}"

exports.createServer = ->
  server = null
  if config.proxy.useShadowsocks
    server = http.createServer serverWithShadowsocks
  else if config.proxy.useHttpProxy
    server = http.createServer serverWithHttpProxy
  else if config.proxy.useSocksProxy
    server = http.createServer serverWithSocksProxy
  else
    server = http.createServer serverWithoutProxy
  server.listen config.poi.listenPort
  console.log "Proxy listening at 127.0.0.1:#{config.poi.listenPort}"

serverWithShadowsocks = (req, res) ->
  console.log "Get Request #{req.url} using Shadowsocks"
  # Shadowsocks
  parsed = url.parse req.url
  options =
    host:       parsed.host || '127.0.0.1'
    hostname:   parsed.hostname || '127.0.0.1'
    port:       parsed.port || 80
    method:     req.method
    path:       parsed.path || '/'
    headers:    req.headers
    socksHost:  '127.0.0.1'
    socksPort:  config.proxy.shadowsocks.localPort
  # Post Data
  postData = ''
  req.setEncoding 'utf8'
  req.addListener 'data', (chunk) ->
    postData += chunk
  req.addListener 'end', ->
    options.postData = req.postData = postData
    sendSocksProxyRequest options, 0, (result) ->
      if result.err
        res.writeHead 500, {'Content-Type': 'text/html'}
        res.write '<DOCTYPE html><html><body><h1>Network Error</h1></body></html>'
        res.end()
      else
        buffers = []
        result.on 'data', (chunk) ->
          buffers.push chunk
        result.on 'end', ->
          data = Buffer.concat buffers
          result.removeAllListeners 'data'
          result.removeAllListeners 'end'
          processor.processData req, data if req.url.indexOf('/kcsapi') != -1
          res.writeHead result.statusCode, result.headers
          res.write data
          res.end()

serverWithSocksProxy = (req, res) ->
  console.log "Get Request #{req.url} using Socks Proxy"
  # Socks
  parsed = url.parse req.url
  options =
    host:       parsed.host || '127.0.0.1'
    hostname:   parsed.hostname || '127.0.0.1'
    port:       parsed.port || 80
    method:     req.method
    path:       parsed.path || '/'
    headers:    req.headers
    socksHost:  config.proxy.socksProxy.socksProxyIp
    socksPort:  config.proxy.socksProxy.socksProxyPort
  # Post Data
  postData = ''
  req.setEncoding 'utf8'
  req.addListener 'data', (chunk) ->
    postData += chunk
  req.addListener 'end', ->
    options.postData = req.postData = postData
    sendSocksProxyRequest options, 0, (result) ->
      if result.err
        res.writeHead 500, {'Content-Type': 'text/html'}
        res.write '<DOCTYPE html><html><body><h1>Network Error</h1></body></html>'
        res.end()
      else
        buffers = []
        result.on 'data', (chunk) ->
          buffers.push chunk
        result.on 'end', ->
          data = Buffer.concat buffers
          result.removeAllListeners 'data'
          result.removeAllListeners 'end'
          processor.processData req, data if req.url.indexOf('/kcsapi') != -1
          res.writeHead result.statusCode, result.headers
          res.write data
          res.end()

serverWithHttpProxy = (req, res) ->
  console.log "Get Request #{req.url} using HTTP Proxy"
  # HTTP Proxy
  options =
    host:     config.proxy.httpProxy.httpProxyIP
    port:     config.proxy.httpProxy.httpProxyPort
    method:   req.method
    path:     req.url
    headers:  req.headers
  # Post Data
  postData = ""
  req.setEncoding 'utf8'
  req.addListener 'data', (chunk) ->
    postData += chunk
  req.addListener 'end', ->
    options.postData = req.postData = postData
    sendHttpRequest options, 0, (result) ->
      if result.err
        res.writeHead 500, {'Content-Type': 'text/html'}
        res.write '<DOCTYPE html><html><body><h1>Network Error</h1></body></html>'
        res.end()
      else
        buffers = []
        result.on 'data', (chunk) ->
          buffers.push chunk
        result.on 'end', ->
          data = Buffer.concat buffers
          result.removeAllListeners 'data'
          result.removeAllListeners 'end'
          processor.processData req, data if req.url.indexOf('/kcsapi') != -1
          res.writeHead result.statusCode, result.headers
          res.write data
          res.end()

serverWithoutProxy = (req, res) ->
  console.log "Get Request #{req.url}"
  # Direct
  parsed = url.parse req.url
  req.host = parsed.host || '127.0.0.1'
  req.hostname = parsed.hostname || '127.0.0.1'
  req.post = parsed.post || 80
  req.path = parsed.path || '/'
  # Post Data
  postData = ""
  req.setEncoding 'utf8'
  req.addListener 'data', (chunk) ->
    postData += chunk
  req.addListener 'end', ->
    req.postData = postData
    sendHttpRequest req, 0, (result) ->
      if result.err
        res.writeHead 500, {'Content-Type': 'text/html'}
        res.write '<DOCTYPE html><html><body><h1>Network Error</h1></body></html>'
        res.end()
      else
        buffers = []
        result.on 'data', (chunk) ->
          buffers.push chunk
        result.on 'end', ->
          data = Buffer.concat buffers
          result.removeAllListeners 'data'
          result.removeAllListeners 'end'
          processor.processData req, data if req.url.indexOf('/kcsapi') != -1
          res.writeHead result.statusCode, result.headers
          res.write data
          res.end()

sendSocksProxyRequest = (options, counter, callback) ->
  request = shttp.request options, (result) ->
    if result.statusCode == 500 || result.statusCode == 502 || result.statusCode == 404 || result.statusCode == 503
      console.log "Code #{result.statusCode}, retried for the #{counter} time."
      if counter != config.antiCat.retryTime
        setTimeout ->
          sendSocksProxyRequest(options, counter + 1, callback)
        , config.antiCat.retryDelay
      else
        callback {err: true}
    else
      callback result
  if options.method == "POST" && options.postData
    request.write options.postData
  request.on 'error', (e) ->
    console.log "#{e}, retried for the #{counter} time."
    if counter != config.antiCat.retryTime
      setTimeout ->
        sendSocksProxyRequest(options, counter + 1, callback)
      , config.antiCat.retryDelay
    else
      callback {err: true}
  request.end()

sendHttpRequest = (options, counter, callback) ->
  request = http.request options, (result) ->
    if result.statusCode == 500 || result.statusCode == 502 || result.statusCode == 404 || result.statusCode == 503
      console.log "Code #{result.statusCode}, retried for the #{counter} time."
      if counter != config.antiCat.retryTime
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
    console.log "#{e}, retried for the #{counter} time."
    if counter != config.antiCat.retryTime
      setTimeout ->
        sendHttpRequest(options, counter + 1, callback)
      , config.antiCat.retryDelay
    else
      callback {err: true}
  request.end()
