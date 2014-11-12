gui = require('nw.gui')
clipboard = gui.Clipboard.get()

currentShowDeck = 0

$ ->
  # Show the window after all is ready
  gui.Window.get().show()
  currentTag = 0
  currentShowDeck = 1
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
  $('#btn-main').click ->
    if currentTag != 0
      currentTag = 0
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-main').fadeIn()
  $('#btn-ship').click ->
    if currentTag != 1
      currentTag = 1
      $('#sec-main').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-ship').fadeIn()
  $('#btn-factory').click ->
    if currentTag != 2
      currentTag = 2
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-calc').hide()
      $('#sec-settings').hide()
      $('#sec-factory').fadeIn()
  $('#btn-calc').click ->
    if currentTag != 3
      currentTag = 3
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-settings').hide()
      $('#sec-calc').fadeIn()
  $('#btn-settings').click ->
    if currentTag != 4
      currentTag = 4
      $('#sec-main').hide()
      $('#sec-ship').hide()
      $('#sec-factory').hide()
      $('#sec-calc').hide()
      $('#sec-settings').fadeIn()
  $('#proxy-tabs').find('a').on 'opened:tabs:amui', (e) ->
    switch $$(this).text()[0]
      when 'S'
        if $$(this).text()[1] == 'h'
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
    require('./modules/ui').saveConfig()
  $('#pac-path').click ->
    clipboard.set $('#pac-path')[0].value, 'text'
    require('./modules/ui').showModal 'PAC文件路径', '路径已经被复制到系统剪切板'
  $('#about-weibo').click ->
    gui.Shell.openExternal 'http://weibo.com/234325654'
  $('#about-github').click ->
    gui.Shell.openExternal 'https://github.com/magimagi/poi'
  $('#about-license').click ->
    gui.Shell.openExternal 'https://github.com/magimagi/poi/blob/master/LICENSE'
  $('#about-nw').click ->
    gui.Shell.openExternal 'https://github.com/rogerwang/node-webkit'

@showDeck = (deckId) ->
  $("#deck-#{currentShowDeck}").hide()
  $("#deck-#{deckId}").fadeIn()
  currentShowDeck = deckId
