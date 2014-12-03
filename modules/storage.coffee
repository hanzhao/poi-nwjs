fs = require('fs')
url = require('url')
mime = require('mime')
util = require('./util')
querystring = require('querystring')
database = window.localStorage
storagePath = "#{global.appDataPath}/storage"

exports.loadStorageFile = (req, res) ->
  parsed = url.parse req.url
  filePath = "#{storagePath}#{parsed.pathname}"
  return false unless fs.existsSync(filePath) && querystring.parse(parsed.query).VERSION == database.getItem(filePath)
  util.log "读取游戏缓存 #{filePath}"
  data = fs.readFileSync filePath
  res.writeHead 200,
    'Content-Type': mime.lookup filePath
    'Content-Length': data.length
  res.write data
  res.end()
  return true

exports.saveStorageFile = (req, data) ->
  parsed = url.parse req.url
  filePath = "#{storagePath}#{parsed.pathname}"
  util.log "保存游戏缓存 #{filePath}"
  util.guaranteeFilePath filePath
  fs.writeFileSync filePath, data
  database.setItem filePath, querystring.parse(parsed.query).VERSION
