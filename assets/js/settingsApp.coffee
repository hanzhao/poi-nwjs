gui = window.require('nw.gui')
clipboard = gui.Clipboard.get()

$ = global.settingsWin.window.$

exports.init = ->
  currentTag = 0
  currentShowDeck = 1
  $('#proxy-tabs').tabs
    noSwipe: 1
  isValidIp = (ip) ->
    match  = ip.match /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/
    if match && 0 <= match[1] && match[1] < 256 && 0 <= match[2] && match[2] < 256 && 0 <= match[3] && match[3] < 256 && 0 <= match[4] && match[4] < 256
      return true
    else
      return false
  isValidPort = (port) ->
    match = port.match /^(\d+)$/
    if match && 0 < match[1] && match[1] < 100000
      return true
    else
      return false
  $('#proxy-tabs').find('a').on 'opened.tabs.amui', (e) ->
    switch $(this).text()[0]
      when 'S'
        if $(this).text()[1] == 'h'
          $('#current-proxy').text 'shadowsocks'
        else
          $('#current-proxy').text 'socks'
      when 'H'
        $('#current-proxy').text 'http'
      else
        $('#current-proxy').text 'none'
  $('#shadowsocks-server-ip').bind 'input', ->
    if isValidIp $('#shadowsocks-server-ip')[0].value
      $('#shadowsocks-server-ip-container').attr 'class', 'am-form-success'
    else
      $('#shadowsocks-server-ip-container').attr 'class', 'am-form-error'
  $('#shadowsocks-server-port').bind 'input', ->
    if isValidPort $('#shadowsocks-server-port')[0].value
      $('#shadowsocks-server-port-container').attr 'class', 'am-form-success'
    else
      $('#shadowsocks-server-port-container').attr 'class', 'am-form-error'
  $('#httpproxy-ip').bind 'input', ->
    if isValidIp $('#httpproxy-ip')[0].value
      $('#httpproxy-ip-container').attr 'class', 'am-form-success'
    else
      $('#httpproxy-ip-container').attr 'class', 'am-form-error'
  $('#httpproxy-port').bind 'input', ->
    if isValidPort $('#httpproxy-port')[0].value
      $('#httpproxy-port-container').attr 'class', 'am-form-success'
    else
      $('#httpproxy-port-container').attr 'class', 'am-form-error'
  $('#socksproxy-ip').bind 'input', ->
    if isValidIp $('#socksproxy-ip')[0].value
      $('#socksproxy-ip-container').attr 'class', 'am-form-success'
    else
      $('#socksproxy-ip-container').attr 'class', 'am-form-error'
  $('#socksproxy-port').bind 'input', ->
    if isValidPort $('#socksproxy-port')[0].value
      $('#socksproxy-port-container').attr 'class', 'am-form-success'
    else
      $('#socksproxy-port-container').attr 'class', 'am-form-error'
  $('#save-proxy-settings').click ->
    window.require('./modules/settingsUi').saveConfig()
  $('#pac-path').click ->
    clipboard.set $('#pac-path')[0].value, 'text'
    window.require('./modules/settingsUi').showModal 'PAC文件路径', '路径已经被复制到系统剪切板'
  $('#about-weibo').click ->
    gui.Shell.openExternal 'http://weibo.com/maginya'
  $('#about-github').click ->
    gui.Shell.openExternal 'https://github.com/nyagi/poi'
  $('#about-license').click ->
    gui.Shell.openExternal 'https://github.com/nyagi/poi/blob/master/LICENSE'
  $('#about-nw').click ->
    gui.Shell.openExternal 'https://github.com/rogerwang/node-webkit'
