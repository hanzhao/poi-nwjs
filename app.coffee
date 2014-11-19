fs = require('fs')
gui = window.require('nw.gui')
if process.platform == 'darwin'
  # OSX: /Users/$user/Library/Application Support/poi
  global.appDataPath = "#{fs.realpathSync(gui.App.dataPath + '/..')}/poi"
else
  # Win or Linux:
  global.appDataPath = fs.realpathSync(process.execPath + '/..')
global.$ = window.$
global.$$ = window.$$
global.Notification = window.Notification
global.Notification.requestPermission()

# Tray
tray = new gui.Tray icon: 'icon.png'
menu = new gui.Menu()
tray.on 'click', ->
  gui.Window.get().show()
show = new gui.MenuItem
  type: 'normal'
  label: '显示'
  click: ->
    gui.Window.get().show()
hide = new gui.MenuItem
  type: 'normal'
  label: '隐藏'
  click: ->
    gui.Window.get().hide()
quit = new gui.MenuItem
  type: 'normal'
  label: '退出'
  click: ->
    gui.Window.get().close true
menu.append show
menu.append hide
menu.append quit
tray.menu = menu
window.tray = tray

# Minimize
win = gui.Window.get()
win.on 'minimize', ->
  this.hide()

# Close
win.on 'close', (quit) ->
  if process.platform == 'darwin' and not quit
    this.hide()
  else
    this.close true

require('./modules/config').loadConfig()
ui = require('./modules/ui')
ui.initConfig()
ui.api_start2_loadDefault()
require('./modules/pac').generatePAC()
require('./modules/cache').initCache()
proxy = require('./modules/proxy')
proxy.createShadowsocksServer()
proxy.createServer()
