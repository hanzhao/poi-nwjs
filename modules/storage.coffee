fs = require('fs')
url = require('url')
util = require('./util')
querystring = require('querystring')
database = window.localStorage
storagePath = "#{global.appDataPath}/storage"

exports.loadStorageFile = (req, res, callback) ->
  parsed = url.parse req.url
  filePath = "#{storagePath}#{parsed.pathname}"
  unless fs.existsSync(parsed.pathname) && querystring.parse(parsed.query).VERSION == database.getItem(filePath)
    callback false
    return
  console.log "Hit Storage! #{filePath}"
  data = fs.readFileSync filePath
  res.writeHead 200,
    'Content-Type': mime.lookup file
    'Content-Length': data.length
  res.write data
  res.end()
  callback true

exports.saveStorageFile = (req, data) ->
  parsed = url.parse req.url
  filePath = "#{storagePath}#{parsed.pathname}"
  console.log "Save Storage! #{filePath}"
  util.guaranteeFilePath filePath
  fs.writeFileSync filePath, data
  database.setItem filePath, querystring.parse(parsed.query).VERSION
