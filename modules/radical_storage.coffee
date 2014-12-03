fs = require('fs')
url = require('url')
mime = require('mime')
util = require('./util')
querystring = require('querystring')
storagePath = "#{global.appDataPath}/cache"

exports.loadStorageFile = (req, res) ->
  parsed = url.parse req.url
  filePath = "#{storagePath}#{parsed.pathname}"
  return false unless fs.existsSync filePath
  util.log "读取自定义缓存 #{filePath}"
  data = fs.readFileSync filePath
  res.writeHead 200,
    'Content-Type': mime.lookup filePath
    'Content-Length': data.length
  res.write data
  res.end()
  return true

