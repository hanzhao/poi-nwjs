config = require('./config')
proxy = config.config.proxy
util = require('./util')
fs = require('fs')

$ = global.settingsWin.window.$

exports.updatePacPath = (path) ->
  $('#pac-path')[0].value = "file://#{path}"

exports.showModal = (title, content) ->
  $('#modal-message-title').text title
  $('#modal-message-content').text content
  $('#modal-message').modal()

exports.showModalHtml = (title, content) ->
  $('#modal-message-title').html title
  $('#modal-message-content').html content
  $('#modal-message').modal()
  
exports.initConfig = ->
  # Update tab state 
  console.log 'in initConfig'
  console.log proxy
  $('#shadowsocks-tab-li').removeClass 'am-active'
  $('#shadowsocks-tab').removeClass 'am-in am-active'
  $('#http-tab-li').removeClass 'am-active'
  $('#http-tab').removeClass 'am-in am-active'
  $('#socks-tab-li').removeClass 'am-active'
  $('#socks-tab').removeClass 'am-in am-active'
  $('#none-tab-li').removeClass 'am-active'
  $('#none-tab').removeClass 'am-in am-active'
  if proxy.useShadowsocks
    $('#current-proxy').text 'shadowsocks'
    $('#shadowsocks-tab-li').addClass 'am-active'
    $('#shadowsocks-tab').addClass 'am-in am-active'
  else if proxy.useHttpProxy
    $('#current-proxy').text 'http'
    $('#http-tab-li').addClass 'am-active'
    $('#http-tab').addClass 'am-in am-active'
  else if proxy.useSocksProxy
    $('#current-proxy').text 'socks'
    $('#socks-tab-li').addClass 'am-active'
    $('#socks-tab').addClass 'am-in am-active'
  else
    $('#current-proxy').text 'none'
    $('#none-tab-li').addClass 'am-active'
    $('#none-tab').addClass 'am-in am-active'
  # Shadowsocks
  $('#shadowsocks-server-ip')[0].value = proxy.shadowsocks.serverIp
  $('#shadowsocks-server-port')[0].value = proxy.shadowsocks.serverPort
  $('#shadowsocks-password')[0].value = proxy.shadowsocks.password
  $('#shadowsocks-method')[0].value = proxy.shadowsocks.method
  # HTTP Proxy
  $('#httpproxy-ip')[0].value = proxy.httpProxy.httpProxyIp
  $('#httpproxy-port')[0].value = proxy.httpProxy.httpProxyPort
  # Socks Proxy
  $('#socksproxy-ip')[0].value = proxy.socksProxy.socksProxyIp
  $('#socksproxy-port')[0].value = proxy.socksProxy.socksProxyPort
  
exports.saveConfig = ->
  conf = config.config
  # Shadowsocks
  conf.proxy.useShadowsocks = $('#current-proxy').text() == 'shadowsocks'
  conf.proxy.shadowsocks.serverIp = $('#shadowsocks-server-ip')[0].value
  conf.proxy.shadowsocks.serverPort = $('#shadowsocks-server-port')[0].value
  conf.proxy.shadowsocks.password = $('#shadowsocks-password')[0].value
  conf.proxy.shadowsocks.method = $('#shadowsocks-method')[0].value
  # HTTP
  conf.proxy.useHttpProxy = $('#current-proxy').text() == 'http'
  conf.proxy.httpProxy.httpProxyIp = $('#httpproxy-ip')[0].value
  conf.proxy.httpProxy.httpProxyPort = $('#httpproxy-port')[0].value
  # Socks
  conf.proxy.useSocksProxy = $('#current-proxy').text() == 'socks'
  conf.proxy.socksProxy.socksProxyIp = $('#socksproxy-ip')[0].value
  conf.proxy.socksProxy.socksProxyPort = $('#socksproxy-port')[0].value
  if config.updateConfig conf
    exports.showModal '保存设置', '保存成功，重新启动软件后生效。'
  else
    exports.showModal '保存设置', '保存失败…'
