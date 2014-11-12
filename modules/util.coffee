fs = require('fs')
path = require('path')

exports.formatTime = (time) ->
  hour = Math.floor(time / 3600)
  time -= hour * 3600
  minute = Math.floor(time / 60)
  time -= minute * 60
  hour = '0' + hour if hour < 10
  minute = '0' + minute if minute < 10
  time = '0' + time if time < 10
  return "#{hour}:#{minute}:#{time}"

guaranteeDirPath = (dirname) ->
  dir = path.dirname dirname
  unless fs.existsSync dir
    guaranteeDirPath dir
  fs.mkdirSync dirname

exports.guaranteeFilePath = guaranteeFilePath = (filename) ->
  console.log "Guarantee #{filename}"
  dir = path.dirname filename
  unless fs.existsSync dir
    guaranteeDirPath dir

exports.copyFile = copyFile = (srcFile, destFile) ->
  console.log "Copy file #{srcFile} to #{destFile}"
  unless fs.existsSync srcFile
    return
  data = fs.readFileSync srcFile
  guaranteeFilePath destFile
  fs.writeFileSync destFile, data