fs = require('fs')
path = require('path')

exports.formatTime = (time) ->
  hour = Math.floor time / 3600
  time -= hour * 3600
  minute = Math.floor time / 60
  time -= minute * 60
  hour = '0' + hour if hour < 10
  minute = '0' + minute if minute < 10
  time = '0' + time if time < 10
  return "#{hour}:#{minute}:#{time}"

guaranteeDirPath = (dirname) ->
  dir = path.dirname dirname
  guaranteeDirPath dir unless fs.existsSync dir
  fs.mkdirSync dirname

exports.guaranteeFilePath = guaranteeFilePath = (filename) ->
  dir = path.dirname filename
  guaranteeDirPath dir unless fs.existsSync dir

exports.copyFile = copyFile = (srcFile, destFile) ->
  return unless fs.existsSync srcFile
  data = fs.readFileSync srcFile
  guaranteeFilePath destFile
  fs.writeFileSync destFile, data

exports.isCacheUrl = (url) ->
  return url.indexOf('/kcs/') != -1 && url.indexOf('Core.swf') == -1 && url.indexOf('mainD2.swf') == -1
