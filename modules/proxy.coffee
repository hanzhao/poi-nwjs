http = require('http')
Buffer = require('buffer').Buffer
config = require('./config')

exports.createServer = ->
  server = http.createServer (req, res) ->
    # HTTP Proxy
    options =
      host:     config.httpProxyIP
      port:     config.httpProxyPort
      method:   req.method
      path:     req.url
      headers:  req.headers
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
          result.removeAllListeners 'data'
          result.removeAllListeners 'end'
          res.writeHead result.statusCode, result.headers
          res.write Buffer.concat buffers
          res.end()
  server.listen config.listenPort
  console.log "Proxy listening at 127.0.0.1:#{config.listenPort}"

sendHTTPProxyRequest = (options, counter, callback) ->
  request = http.request options, (result) ->
    if result.statusCode == 500 || result.statusCode == 502 || result.statusCode == 404 || result.statusCode == 503
      console.log "Code #{result.statusCode}, retried for the #{counter} time."
      if counter < 100
        setTimeout ->
          sendHTTPProxyRequest(options, counter + 1, callback)
        , config.retryDelay
      else
        callback {err: true}
    else
      callback result
  request.on 'error', (e) ->
    console.log "#{e}, retried for the #{counter} time."
    if counter < 100
      setTimeout ->
        sendHTTPProxyRequest(options, counter + 1, callback)
      , config.retryDelay
    else
      callback {err: true}
  request.end()
