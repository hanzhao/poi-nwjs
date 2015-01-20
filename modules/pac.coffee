fs = require('fs')
ui = require('./ui')
config = require('./config').config
proxy = config.proxy

pacPath = null
if process.platform != 'win32' && process.platform != 'win64'
  pacPath = "#{global.appDataPath}/proxy.pac"
else
  pacPath = "#{global.appDataPath}\\proxy.pac"
ui.updatePacPath pacPath

upstream = "DIRECT"
upstreamIp = ""
upstreamPort = ""
upstreamString = ""
if proxy.useShadowsocks
  upstream = "SOCKS5"
  upstreamIp = "127.0.0.1"
  upstreamPort = proxy.shadowsocks.localPort
else if proxy.useHttpProxy
  upstream = "PROXY"
  upstreamIp = proxy.httpProxy.httpProxyIp
  upstreamPort = proxy.httpProxy.httpProxyPort
else if proxy.useSocksProxy
  upstream = "SOCKS5"
  upstreamIp = proxy.socksProxy.socksProxyIp
  upstreamIp = proxy.socksProxy.socksProxyPort

if upstream == "DIRECT"
  upstreamString = "DIRECT"
else
  upstreamString = "#{upstream} #{upstreamIp}:#{upstreamPort}"

pacString = [
  'var processHost = {',
  '  "203.104.209.7":      true,',
  '  "203.104.105.167":    true,',
  '  "203.104.209.71":     true,',
  '  "125.6.184.15":       true,',
  '  "125.6.184.16":       true,',
  '  "125.6.187.205":      true,',
  '  "125.6.187.229":      true,',
  '  "125.6.187.253":      true,',
  '  "125.6.188.25":       true,',
  '  "203.104.248.135":    true,',
  '  "125.6.189.7":        true,',
  '  "125.6.189.39":       true,',
  '  "125.6.189.71":       true,',
  '  "125.6.189.103":      true,',
  '  "125.6.189.135":      true,',
  '  "125.6.189.167":      true,',
  '  "125.6.189.215":      true,',
  '  "125.6.189.247":      true,',
  '  "203.104.209.23":     true,',
  '  "203.104.209.39":     true,',
  '  "203.104.209.55":     true'
  '};',
  'var proxyHost = {',
  '  "wikiwiki.jp":        true,',
  '  "public.wikiwiki.jp": true,',
  '  "www.dmm.com":        true,',
  '  "my.dmm.com":         true,',
  '  "my.dmm.co.jp":       true,',
  '  "www.dmm.co.jp":      true,',
  '  "osapi.dmm.com":      true,',
  '  "osapi.dmm.co.jp":    true,',
  '  "sp.dmm.com":         true,',
  '  "google.co.jp":       true,',
  '  "google.com":         true,',
  '  "google.com.hk":      true,',
  '  "google.cn":          true,',
  '  "www.google.co.jp":   true,',
  '  "www.google.com":     true,',
  '  "www.google.com.hk":  true,',
  '  "www.google.cn":      true,',
  '  "mail.google.com":    true,',
  '  "image.google.com":   true,',
  '  "ajax.googleapis.com":true,',
  '  "twitter.com":        true,',
  '  "www.twitter.com":    true',
  '};',
  "var poiProxy = \"PROXY 127.0.0.1:#{config.poi.listenPort}\";",
  "var upstreamProxy = \"#{upstreamString}\";",
  'function FindProxyForURL(url, host) {',
  '  if (url == "http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/")',
  '    return poiProxy',
  '  if (processHost[host])',
  '    return poiProxy;',
  '  if (proxyHost[host])',
  '    return upstreamProxy;',
  '  return "DIRECT";',
  '}'
].join "\n"

exports.generatePAC = ->
  fs.writeFileSync pacPath, pacString
