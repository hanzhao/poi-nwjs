config = require('./config')
proxy = config.config.proxy
util = require('./util')

$ = global.$
$$ = global.$$
Notification = global.Notification

materialsName = ['', '油', '弹', '钢', '铝', '高速建造', '高速修复', '开发资材', '改修资材']

state = false

antiCatCounter = 0

missionTimer = [-1, -1, -1, -1, -1]
ndockTimer = [-1, -1, -1, -1, -1]
kdockTimer = [-1, -1, -1, -1, -1]

user = null
createitem = null
ships = []
stypes = []
mapareas = []
maps = []
missions = []
slotitems = []
ownShips = []
ownSlotitems = []
materials = []
decks = []
ndocks = []
kdocks = []

exports.updatePacPath = (path) ->
  $('#pac-path')[0].value = "file://#{path}"

exports.showNotification = showNotification = (body) ->
  notification = new Notification 'Poi',
    body: body
  notification.onclick = ->
    notification.close()

timer = ->
  for i in [1, 2, 3, 4]
    missionTimer[i] -= 1 if missionTimer[i] > 0
    if missionTimer[i] >= 0
      $("#mission-timer-#{i}").text util.formatTime missionTimer[i]
      showNotification "#{$("#mission-name-#{i}").text()}远征归来" if missionTimer[i] == 50
    else
      $("#mission-timer-#{i}").text ''
    ndockTimer[i] -= 1 if ndockTimer[i] > 0
    if ndockTimer[i] >= 0
      $("#ndock-timer-#{i}").text util.formatTime ndockTimer[i]
      showNotification "#{$("#ndock-name-#{i}").text()}修复完成" if missionTimer[i] == 50
    else
      $("#ndock-timer-#{i}").text ''
    kdockTimer[i] -= 1 if kdockTimer[i] > 0
    if kdockTimer[i] >= 0
      $("#kdock-timer-#{i}").text util.formatTime kdockTimer[i]
      $("#kdock-#{i}-remaining").text util.formatTime kdockTimer[i]
      showNotification "#{$("#kdock-name-#{i}").text()}建造完成" if missionTimer[i] == 50
    else
      $("#kdock-timer-#{i}").text ''
      $("#kdock-#{i}-remaining").text ''

exports.initConfig = ->
  # Update tab state
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
    $('#modal-message-title').text '保存设置'
    $('#modal-message-content').text '保存成功，重新启动软件后生效。'
    $$('#modal-message').modal()
  else
    $('#modal-message-title').text '保存设置'
    $('#modal-message-content').text '保存失败'
    $$('#modal-message').modal()

exports.turnOn = ->
  if !state
    state = true
    $('#state-panel-content').text '正常运行中'
    $('#state-panel').hide()
    $('#user-panel').fadeIn()
    $('#resource-panel').fadeIn()
    $('#mission-panel').fadeIn()
    $('#ndocks-panel').fadeIn()
    $('#kdocks-panel').fadeIn()
    $('#anticat-panel').fadeIn()
    setInterval timer, 1000

exports.turnOff = ->
  if state
    state = false
    $('#state-panel-content').text '没有检测到流量'
    $('#user-panel').hide()
    $('#resource-panel').hide()
    $('#mission-panel').hide()
    $('#ndocks-panel').hide()
    $('#kdocks-panel').hide()
    $('#anticat-panel').hide()
    $('#state-panel').fadeIn()

exports.addAntiCatCounter = ->
  $('#anticat-panel-content').text "一共抵御了#{antiCatCounter += 1}次猫神的袭击……"

################################################################################

exports.updateGameData = (api_data) ->
  ships = []
  ships[ship.api_id] = ship for ship in api_data.api_mst_ship
  stypes = []
  stypes[stype.api_id] = stype for stype in api_data.api_mst_stype
  slotitems = []
  slotitems[slotitem.api_id] = slotitem for slotitem in api_data.api_mst_slotitem
  mapareas = []
  mapareas[maparea.api_id] = maparea for maparea in api_data.api_mst_maparea
  maps = []
  maps[map.api_id] = map for map in api_data.api_mst_mapinfo
  missions = []
  missions[mission.api_id] = mission for mission in api_data.api_mst_mission

exports.updateUserData = (api_data) ->
  user = api_data

exports.updateSlotitemData = (api_data) ->
  ownSlotitems = []
  ownSlotitems[slotitem.api_id] = slotitem for slotitem in api_data

exports.updatePortData = (api_data) ->
  material = []
  materials[material.api_id] = material for material in api_data.api_material
  ownShips = []
  ownShips[ship.api_id] = ship for ship in api_data.api_ship
  decks = []
  decks[deck.api_id] = deck for deck in api_data.api_deck_port
  ndocks = []
  ndocks[ndock.api_id] = ndock for ndock in api_data.api_ndock

exports.updateKdocksData = (api_data) ->
  kdocks = []
  kdocks[kdock.api_id] = kdock for kdock in api_data

exports.updateCreateitemData = (api_data) ->
  createitem = api_data

###############################################################################

exports.refreshUser = ->
  html = "<li>Lv. #{user.api_level} #{user.api_nickname}</li>"
  $('#user-panel-content').html html

exports.refreshMaterials = ->
  for material in materials
    continue unless material
    $("#material-#{material.api_id}").text "#{materialsName[material.api_id]}: #{material.api_value}"

exports.refreshDecks = ->
  for deck in decks
    continue unless deck?
    totalLv = 0
    # Deckname
    $("#deckname-#{deck.api_id}").text deck.api_name
    $("#mission-name-#{deck.api_id}").text deck.api_name
    # Mission
    switch deck.api_mission[0]
      when 0
        missionTimer[deck.api_id] = -1
      when 1
        missionTimer[deck.api_id] = Math.floor((deck.api_mission[2] - new Date()) / 1000)
      when 2
        missionTimer[deck.api_id] = 0
    for shipId, i in deck.api_ship
      if shipId != -1
        ship = ownShips[shipId]
        totalLv += ship.api_lv
        $("#ship-#{deck.api_id}#{i + 1}-type").text stypes[ships[ship.api_ship_id].api_stype].api_name
        $("#ship-#{deck.api_id}#{i + 1}-exp").text "Next: #{ship.api_exp[1]}"
        $("#ship-#{deck.api_id}#{i + 1}-hp").text "HP: #{ship.api_nowhp} / #{ship.api_maxhp}"
        $("#ship-#{deck.api_id}#{i + 1}-cond").text "Cond. #{ship.api_cond}"
        if ship.api_cond < 20
          $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', 'mg-red'
        else if ship.api_cond < 30
          $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', 'mg-orange'
        else if ship.api_cond > 49
          $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', 'mg-yellow'
        else
          $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', ''

        $("#ship-#{deck.api_id}#{i + 1}-name").text ships[ship.api_ship_id].api_name
        $("#ship-#{deck.api_id}#{i + 1}-lv").text "Lv. #{ship.api_lv}"

        # HP Line
        hpPercent = ship.api_nowhp * 100 / ship.api_maxhp
        currentState = 'am-progress-bar-success'
        currentState = 'am-progress-bar-secondary' if hpPercent < 75
        currentState = 'am-progress-bar-warning' if hpPercent < 50
        currentState = 'am-progress-bar-danger' if hpPercent < 25
        $("#ship-#{deck.api_id}#{i + 1}-hpline").html "<div class=\"am-progress am-progress-striped\"><div class=\"am-progress-bar #{currentState}\" style=\"width: #{hpPercent}%\"></div></div>"

        # Equipment
        # $("#ship-#{deck.api_id}#{i + 1}-equip")
      else
        $("#ship-#{deck.api_id}#{i + 1}-type").text ''
        $("#ship-#{deck.api_id}#{i + 1}-exp").text ''
        $("#ship-#{deck.api_id}#{i + 1}-hp").text ''
        $("#ship-#{deck.api_id}#{i + 1}-cond").text ''
        $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', ''

        $("#ship-#{deck.api_id}#{i + 1}-name").text ''
        $("#ship-#{deck.api_id}#{i + 1}-lv").text ''
        $("#ship-#{deck.api_id}#{i + 1}-hpline").html ''
    $("#deck-#{deck.api_id}-info").text "总计Lv. #{totalLv}"

exports.refreshNdocks = ->
  for ndock in ndocks
    continue unless ndock
    switch ndock.api_state
      when -1
        $("#ndock-name-#{ndock.api_id}").text '未解锁'
      when 0
        $("#ndock-name-#{ndock.api_id}").text '未使用'
        ndockTimer[ndock.api_id] = -1
      when 1
        ship = ownShips[ndock.api_ship_id]
        $("#ndock-name-#{ndock.api_id}").text ships[ship.api_ship_id].api_name
        ndockTimer[ndock.api_id] = Math.floor((ndock.api_complete_time - new Date()) / 1000)

exports.refreshKdocks = ->
  for kdock in kdocks
    continue unless kdock
    switch kdock.api_state
      when -1
        $("#kdock-#{kdock.api_id}-name").text '未解锁'
        $("#kdock-name-#{kdock.api_id}").text '未解锁'
      when 0
        $("#kdock-#{kdock.api_id}-name").text '未使用'
        $("#kdock-name-#{kdock.api_id}").text '未使用'
        $("#kdock-#{kdock.api_id}-material").text ''
        kdockTimer[kdock.api_id] = -1
      when 1 #大建中
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = Math.floor((kdock.api_complete_time - new Date()) / 1000)
        materialStr = "油 #{kdock.api_item1} 钢 #{kdock.api_item3} 弹 #{kdock.api_item2} 铝 #{kdock.api_item4} 资 #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").text materialStr
      when 2 #普建中
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = Math.floor((kdock.api_complete_time - new Date()) / 1000)
        materialStr = "油 #{kdock.api_item1} 钢 #{kdock.api_item3} 弹 #{kdock.api_item2} 铝 #{kdock.api_item4} 资 #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").text materialStr
      when 3
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = 0
        materialStr = "油 #{kdock.api_item1} 钢 #{kdock.api_item3} 弹 #{kdock.api_item2} 铝 #{kdock.api_item4} 资 #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").text materialStr

exports.refreshCreateitem = ->
  switch createitem.api_create_flag
    when 0 #失败
      $("#createitem-state").attr "class" , "am-btn am-btn-danger"
      $("#createitem-state").text "失败"  
      str =  createitem.api_fdata
      createitemNum = parseInt(str.substr(str.indexOf(',') + 1) , 10)
      $("#createitem-name").text slotitems[createitemNum].api_name
    when 1 #成功
      $("#createitem-state").attr "class" , "am-btn am-btn-success"
      $("#createitem-state").text "成功"
      $("#createitem-name").text slotitems[createitem.api_slot_item.api_slotitem_id].api_name