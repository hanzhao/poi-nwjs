fs = require('fs')
url = require('url')
util = require('./util')

# Load File From Cache
exports.loadCacheFile = (req, res, callback) ->
  # These two swf files are source code files, not resource files
  # Caching these files may cause illegal logic error I guess?
  if req.url.indexOf('/kcs/Core.swf') != -1 || req.url.indexOf('/kcs/mainD2.swf') != -1
    callback true
    return
  if req.url.indexOf('/kcs/') != -1
    # Get FilePath
    filePath = url.parse(req.url).pathname.substr 1
    filePath = "cache/#{filePath}"
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
exports.saveCacheFile = (req, data) ->
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
