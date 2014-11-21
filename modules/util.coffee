fs = require('fs')
path = require('path')
zlib = require('zlib')
iconv = require('iconv-lite')
iconv.extendNodeEncodings()

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

exports.modifyPage = (data, gzip, callback) ->
  if gzip
    zlib.gunzip data, (err, res) ->
      callback data if err
      data = res
      str = data.toString('euc-jp')
      callback data if str.indexOf('<div id="area-game">') == -1
      s = str.split '<div id="area-game">'
      str = s[0] + '<div id="area-game" style="text-align: left;">' + s[1]
      str = str.replace ' lang="ja"', ''
      str = str.replace 'charset=euc-jp', 'charset=utf-8'
      str = str.replace '艦隊これくしょん～艦これ～ - オンラインゲーム - DMM.com', '～艦これ～Poi～'
      zlib.gzip str, (err, result) ->
        callback data if err
        callback result
  else
    str = data.toString('euc-jp')
    callback data if str.indexOf('<div id="area-game">') == -1
    s = str.split '<div id="area-game">'
    str = s[0] + '<div id="area-game" style="text-align: left;">' + s[1]
    str = str.replace ' lang="ja"', ''
    str = str.replace 'charset=euc-jp', 'charset=utf-8'
    str = str.replace '艦隊これくしょん～艦これ～ - オンラインゲーム - DMM.com', '～艦これ～Poi～'
    callback str


exports.log = (text) ->
  console.log text
  global.$('#log-panel-content').text text
