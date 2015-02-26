fs = require('fs')
gui = window.require('nw.gui')
if process.platform == 'darwin'
  # OSX: /Users/$user/Library/Application Support/poi
  global.appDataPath = "#{fs.realpathSync(gui.App.dataPath + '/..')}/poi"
else
  # Win or Linux:
  global.appDataPath = fs.realpathSync(process.execPath + '/..')
global.$ = window.$
global.Notification = window.Notification
global.Notification.requestPermission()
global.win = win = gui.Window.get()
global.settingsWin = settingsWin =
  gui.Window.open "settings.html",
    "show": false
    "position": "center"
    "toolbar": false
    "resizable": false
    "width": 600
    "height": 725

# Always on Top
win.setAlwaysOnTop true
settingsWin.setAlwaysOnTop true

# Tray
tray = null
if process.platform != 'darwin'
  tray = new gui.Tray
    icon: 'icon.png'
else
  tray = new gui.Tray
    icon: 'icon_16x16.png'
menu = new gui.Menu()
tray.on 'click', ->
  win.show()
show = new gui.MenuItem
  type: 'normal'
  label: '显示'
  click: ->
    win.show()
hide = new gui.MenuItem
  type: 'normal'
  label: '隐藏'
  click: ->
    win.hide()
settings = new gui.MenuItem
  type: 'normal'
  label: '设置'
  click: ->
    win.setAlwaysOnTop false
    settingsWin.show()
debug = new gui.MenuItem
  type: 'normal'
  label: '调试'
  click: ->
    win.showDevTools()
debug2 = new gui.MenuItem
  type: 'normal'
  label: '调试Settings'
  click: ->
    settingsWin.showDevTools()
quit = new gui.MenuItem
  type: 'normal'
  label: '退出'
  click: ->
    settingsWin.close true
    win.close true

menu.append show
menu.append hide
menu.append settings
# menu.append debug
# menu.append debug2
menu.append quit
tray.menu = menu
window.tray = tray

# Minimize
win.on 'minimize', ->
  this.hide()

# Close
win.on 'close', (quit) ->
  if not quit
    this.hide()
  else
    this.close true
settingsWin.on 'close', (quit) ->
  win.setAlwaysOnTop true
  if not quit
    this.hide()
  else
    this.close true

require('./modules/config').loadConfig()
ui = require('./modules/ui')
ui.api_start2_loadDefault()
require('./modules/cache').initCache()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
