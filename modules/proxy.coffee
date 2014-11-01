http = require('http')
fs = require('fs')
config = require('./config')
Buffer = require('buffer').Buffer
processor = require('./processor')

exports.createServer = ->
  server = http.createServer (req, res) ->
    # HTTP Proxy
    options =
      host:     config.httpProxyIP
      port:     config.httpProxyPort
      method:   req.method
      path:     req.url
      headers:  req.headers
    console.log(req.url)
    # Post Data
    postData = ""
    req.setEncoding 'utf8'
    req.addListener 'data', (chunk) ->
      postData += chunk
    req.addListener 'end', ->
      options.postData = req.postData = postData
      sendHTTPProxyRequest options, 0, (result) ->
        if result.err
          res.writeHead 500, {"Content-Type": "text/html"}
          res.write 'Network Error!'
          res.end()
        else
          buffers = []
          result.on 'data', (chunk) ->
            buffers.push chunk
          result.on 'end', ->
            data = Buffer.concat buffers
            result.removeAllListeners 'data'
            result.removeAllListeners 'end'
            processor.processData req, data unless req.url.indexOf('/kcsapi') == -1
            res.writeHead result.statusCode, result.headers
            res.write data
            res.end()
  server.listen config.listenPort
  console.log "Proxy listening at 127.0.0.1:#{config.listenPort}"

sendHTTPProxyRequest = (options, counter, callback) ->
  request = http.request options, (result) ->
    if result.statusCode == 500 || result.statusCode == 502 || result.statusCode == 404 || result.statusCode == 503
      console.log "Code #{result.statusCode}, retried for the #{counter} time."
      if counter < config.retryTime
        setTimeout ->
          sendHTTPProxyRequest(options, counter + 1, callback)
        , config.retryDelay
      else
        callback {err: true}
    else
      callback result
  if options.method == "POST" && options.postData
    request.write options.postData
  request.on 'error', (e) ->
    console.log "#{e}, retried for the #{counter} time."
    if counter < config.retryTime
      setTimeout ->
        sendHTTPProxyRequest(options, counter + 1, callback)
      , config.retryDelay
    else
      callback {err: true}
  request.end()
