config = require('./config')
proxy = config.config.proxy
util = require('./util')
fs = require('fs')

$ = global.$
$$ = global.$$
Notification = global.Notification

materialsName = ['', '油', '弹', '钢', '铝', '高速建造', '高速修复', '开发资材', '改修资材']
rankName = ['', '元帥', '大将', '中将', '少将', '大佐', '中佐', '新米中佐', '少佐', '中堅少佐', '新米少佐']
exp = [0, 0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500, 6600, 7800, 9100, 10500, 12000, 13600, 15300, 17100, 19000, 21000, 23100, 25300, 27600, 30000, 32500, 35100, 37800, 40600, 43500, 46500, 49600, 52800, 56100, 59500, 63000, 66600, 70300, 74100, 78000, 82000, 86100, 90300, 94600, 99000, 103500, 108100, 112800, 117600, 122500, 127500, 132700, 138100, 143700, 149500, 155500, 161700, 168100, 174700, 181500, 188500, 195800, 203400, 211300, 219500, 228000, 236800, 245900, 255300, 265000, 275000, 285400, 296200, 307400, 319000, 331000, 343400, 356200, 369400, 383000, 397000, 411500, 426500, 442000, 458000, 474500, 491500, 509000, 527000, 545500, 564500, 584500, 606500, 631500, 661500, 701500, 761500, 851500, 1000000, 1000000, 1010000, 1011000, 1013000, 1016000, 1020000, 1025000, 1031000, 1038000, 1046000, 1055000, 1065000, 1077000, 1091000, 1107000, 1125000, 1145000, 1168000, 1194000, 1223000, 1255000, 1290000, 1329000, 1372000, 1419000, 1470000, 1525000, 1584000, 1647000, 1714000, 1785000, 1860000, 1940000, 2025000, 2115000, 2210000, 2310000, 2415000, 2525000, 2640000, 2760000, 2887000, 3021000, 3162000, 3310000, 3465000, 3628000, 3799000, 3978000, 4165000, 4360000, 4360000]

state = false

antiCatCounter = 0

missionTimer = [-1, -1, -1, -1, -1]
ndockTimer = [-1, -1, -1, -1, -1]
kdockTimer = [-1, -1, -1, -1, -1]

user = null
createItem = null
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
    icon: 'icon.png'
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

exports.showModal = (title, content) ->
  $('#modal-message-title').text title
  $('#modal-message-content').text content
  $$('#modal-message').modal()

exports.showModalHtml = (title, content) ->
  $('#modal-message-title').html title
  $('#modal-message-content').html content
  $$('#modal-message').modal()


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
    exports.showModal '保存设置', '保存成功，重新启动软件后生效。'
  else
    exports.showModal '保存设置', '保存失败…'

exports.turnOn = ->
  if !state
    state = true
    $('#state-panel-content').text '正常运行中'
    $('#poi-panel').hide()
    $('#user-panel').fadeIn()
    $('#resource-panel').fadeIn()
    $('#mission-panel').fadeIn()
    $('#ndocks-panel').fadeIn()
    $('#kdocks-panel').fadeIn()
    $('#log-panel').fadeIn()
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
    $('#log-panel').hide()
    $('#poi-panel').fadeIn()

exports.addAntiCatCounter = ->
  $('#anticat-panel-content').text "一共抵御了#{antiCatCounter += 1}次猫神的袭击……"

getMaterialImgTag = (id) ->
  return "<img src=\"./assets/images/material/#{id}.png\" title=\"#{materialsName[id]}\" style=\"height: 30px; margin-right: 1px;\">"

getMaterialImgTag2 = (id) ->
  return "<img src=\"./assets/images/material/#{id}.png\" title=\"#{materialsName[id]}\" style=\"height: 30px; margin-right: 20px;\">"

################################################################################

api_start2_filePath = 'data/api_start2.json'
api_start2_realPath = "#{global.appDataPath}/#{api_start2_filePath}"

exports.api_start2_loadDefault = () ->
  data = []
  try
    data = JSON.parse fs.readFileSync api_start2_realPath
  catch err
    data = JSON.parse fs.readFileSync api_start2_filePath
  api_start2 data

exports.api_start2 = api_start2 = (data) ->
  api_data = data.api_data
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
  util.guaranteeFilePath api_start2_realPath
  fs.writeFile api_start2_realPath, JSON.stringify(data), (err) ->
    console.log err if err?

exports.api_get_member_basic = (api_data) ->
  user = api_data

exports.api_get_member_slot_item = (api_data) ->
  ownSlotitems = []
  ownSlotitems[slotitem.api_id] = slotitem for slotitem in api_data

exports.api_port_port = (api_data) ->
  material = []
  materials[material.api_id] = material for material in api_data.api_material
  ownShips = []
  ownShips[ship.api_id] = ship for ship in api_data.api_ship
  decks = []
  decks[deck.api_id] = deck for deck in api_data.api_deck_port
  ndocks = []
  ndocks[ndock.api_id] = ndock for ndock in api_data.api_ndock
  user = api_data.api_basic

exports.api_get_member_kdock = (api_data) ->
  kdocks = []
  kdocks[kdock.api_id] = kdock for kdock in api_data

exports.api_get_member_ship2 = (data) ->
  ownShips = []
  ownShips[ship.api_id] = ship for ship in data.api_data
  decks = []
  decks[deck.api_id] = deck for deck in data.api_data_deck

exports.api_get_member_ship3 = (api_data) ->
  ownShips = []
  ownShips[ship.api_id] = ship for ship in api_data.api_ship_data
  decks = []
  decks[deck.api_id] = deck for deck in api_data.api_deck_data

exports.api_req_hokyu_charge = (api_data) ->
  for ship in api_data.api_ship
    shipId = ship.api_id
    for k, v of ship
      ownShips[shipId][k] = v

exports.api_req_kousyou_createitem = (api_data) ->
  createItem = api_data
  if api_data.api_create_flag == 1
    ownSlotitems[api_data.api_slot_item.api_id] = api_data.api_slot_item

exports.api_req_kousyou_getship = (api_data) ->
  kdocks = []
  kdocks[kdock.api_id] = kdock for kdock in api_data.api_kdock
  ownShips[api_data.api_ship.api_id] = api_data.api_ship

exports.api_req_kaisou_slotset = (postData, api_data) ->
  shipId = parseInt postData.api_id
  itemId = parseInt postData.api_item_id
  idx = parseInt postData.api_slot_idx
  ownShips[shipId].api_slot[idx] = itemId

exports.api_req_mission_start = (postData, api_data) ->
  deckId = parseInt postData.api_deck_id
  missionId = parseInt postData.api_mission_id
  decks[deckId].api_mission[0] = 1
  decks[deckId].api_mission[1] = missionId
  # The complatetime is a typo in game api
  decks[deckId].api_mission[2] = api_data.api_complatetime

###############################################################################

exports.refreshUser = ->
  text = "Lv. #{user.api_level} #{user.api_nickname} [#{rankName[user.api_rank]}]"
  $('#user-panel-title').text text
  shipCount = 0
  for ship in ownShips
    shipCount += 1 if ship
  text = "舰娘: #{shipCount} / #{user.api_max_chara}"
  $('#chara-info').text text
  slotitemCount = 0
  for slotitem in ownSlotitems
    continue unless slotitem
    slotitemCount += 1
  text = "装备: #{slotitemCount} / #{user.api_max_slotitem}"
  $('#equip-info').text text
  for material in materials
    continue unless material
    $("#material-#{material.api_id}").html "#{getMaterialImgTag2 material.api_id} #{material.api_value}"

exports.refreshDecks = ->
  for deck in decks
    continue unless deck?
    # Level
    totalLv = 0
    # Ship
    totalShip = 0
    # Saku
    totalSaku = 0
    # Tyku
    totalTyku = 0
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
        basicSaku = 0
        extraSaku = 0
        extraTyku = 0
        if ship.api_sakuteki[0]
          basicSaku += ship.api_sakuteki[0]
        shipData = ships[ship.api_ship_id]
        $("#ship-#{deck.api_id}#{i + 1}-type").text stypes[shipData.api_stype].api_name
        $("#ship-#{deck.api_id}#{i + 1}-exp").text "Next: #{ship.api_exp[1]}"

        fuelPercent = ship.api_fuel * 100 / shipData.api_fuel_max
        currentState = 'am-progress-bar-success'
        currentState = 'mg-progress-bar-yellow' if fuelPercent < 100
        currentState = 'am-progress-bar-warning' if fuelPercent < 75
        currentState = 'am-progress-bar-danger' if fuelPercent < 50
        fuelChargeHtml = "<div class=\"am-progress am-progress-sm mg-progress-inline\"><div class=\"am-progress-bar #{currentState}\" style=\"width: #{fuelPercent}%\"></div></div>"
        bullPercent = ship.api_bull * 100 / shipData.api_bull_max
        currentState = 'am-progress-bar-success'
        currentState = 'mg-progress-bar-yellow' if bullPercent < 100
        currentState = 'am-progress-bar-warning' if bullPercent < 75
        currentState = 'am-progress-bar-danger' if bullPercent < 50
        bullChargeHtml = "<div class=\"am-progress am-progress-sm mg-progress-inline\"><div class=\"am-progress-bar #{currentState}\" style=\"width: #{bullPercent}%\"></div></div>"
        $("#ship-#{deck.api_id}#{i + 1}-charge").html "#{fuelChargeHtml}<div class=\"mg-progress-split\"></div>#{bullChargeHtml}<div class=\"clear\"></div>"

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
        currentState = 'mg-progress-bar-yellow' if hpPercent < 75
        currentState = 'am-progress-bar-warning' if hpPercent < 50
        currentState = 'am-progress-bar-danger' if hpPercent < 25
        $("#ship-#{deck.api_id}#{i + 1}-hpline").html "<div class=\"am-progress am-progress-striped\"><div class=\"am-progress-bar #{currentState}\" style=\"width: #{hpPercent}%\">HP: #{ship.api_nowhp} / #{ship.api_maxhp}</div></div>"

        # Equipment
        html = '<ul class="sm-block-grid-4">'
        for slotId, slotPos in ship.api_slot
          break if slotPos == 4
          cur = '<li></li>'
          if slotId != -1
            slot = ownSlotitems[slotId]
            if slot?
              slotData = slotitems[slot.api_slotitem_id]
              if slotData.api_type[3] == 12 || slotData.api_type[3] == 13
                extraSaku += slotData.api_saku * 2
              else if slotData.api_type[3] >= 9 && slotData.api_type[3] <= 11
                extraSaku += slotData.api_saku
              else if slotData.api_saku
                basicSaku += slotData.api_saku
              if ship.api_onslot[slotPos] > 0 && slotData.api_type[3] >= 6 && slotData.api_type[3] <= 9 && slotData.api_tyku > 0
                extraTyku += Math.floor(slotData.api_tyku * (Math.sqrt(ship.api_onslot[slotPos])))
              cur = "<li><div class=\"mg-ico-container\"><img src=\"./assets/images/slotitem/#{slotData.api_type[3]}.png\" title=\"#{slotData.api_name}\"></img></div></li>"
            else
              cur = '<li><div class="\"mg-ico-container\"><img src="./assets/images/slotitem/0.png" title="？？？"></img></div></li>'
          html += cur
        html += '</ul>'
        $("#ship-#{deck.api_id}#{i + 1}-equip").html html
        totalShip += 1
        totalLv += ship.api_lv
        totalSaku += Math.floor(Math.sqrt(basicSaku)) + extraSaku
        totalTyku += extraTyku
      else
        $("#ship-#{deck.api_id}#{i + 1}-type").text ''
        $("#ship-#{deck.api_id}#{i + 1}-exp").text ''
        $("#ship-#{deck.api_id}#{i + 1}-charge").html ''
        $("#ship-#{deck.api_id}#{i + 1}-cond").text ''
        $("#ship-#{deck.api_id}#{i + 1}-cond").attr 'class', ''

        $("#ship-#{deck.api_id}#{i + 1}-name").text ''
        $("#ship-#{deck.api_id}#{i + 1}-lv").text ''
        $("#ship-#{deck.api_id}#{i + 1}-hpline").html ''
        $("#ship-#{deck.api_id}#{i + 1}-equip").html ''
    html = "<span class=\"mg-text-split\">总计Lv. #{totalLv}</span>"
    html += "<span class=\"mg-text-split\">平均Lv. #{(totalLv / totalShip).toFixed(0)}</span>"
    html += "<span class=\"mg-text-split\">制空: #{totalTyku}</span>"
    html += "<span class=\"mg-text-split\">索敌: #{totalSaku}</span>"
    $("#deck-#{deck.api_id}-info").html html

exports.refreshNdocks = ->
  for ndock in ndocks
    continue unless ndock
    switch ndock.api_state
      when -1
        $("#ndock-name-#{ndock.api_id}").css 'background-color', 'rgba(221, 81, 76, 0.05)'
        $("#ndock-timer-#{ndock.api_id}").css 'background-color', 'rgba(221, 81, 76, 0.05)'
      when 0
        $("#ndock-name-#{ndock.api_id}").attr 'style', ''
        $("#ndock-timer-#{ndock.api_id}").attr 'style', ''
        $("#ndock-name-#{ndock.api_id}").text ''
        ndockTimer[ndock.api_id] = -1
      when 1
        ship = ownShips[ndock.api_ship_id]
        $("#ndock-name-#{ndock.api_id}").attr 'style', ''
        $("#ndock-timer-#{ndock.api_id}").attr 'style', ''
        $("#ndock-name-#{ndock.api_id}").text ships[ship.api_ship_id].api_name
        ndockTimer[ndock.api_id] = Math.floor((ndock.api_complete_time - new Date()) / 1000)

exports.refreshKdocks = ->
  clearKdock = (id) ->
    $("#kdock-name-#{id}").attr 'style', ''
    $("#kdock-timer-#{id}").attr 'style', ''
    $("#kdock-#{id}-name").attr 'style', ''
    $("#kdock-#{id}-remaining").attr 'style', ''
    $("#kdock-#{id}-material").attr 'style', ''
    $("#kdock-#{id}-name").text ''
    $("#kdock-name-#{id}").text ''
    $("#kdock-#{id}-material").html ''
  for kdock in kdocks
    continue unless kdock
    switch kdock.api_state
      when -1
        clearKdock kdock.api_id
        # Main page
        $("#kdock-name-#{kdock.api_id}").css 'background-color', 'rgba(221, 81, 76, 0.05)'
        $("#kdock-timer-#{kdock.api_id}").css 'background-color', 'rgba(221, 81, 76, 0.05)'
        # Factory page
        $("#kdock-#{kdock.api_id}-name").css 'background-color', 'rgba(221, 81, 76, 0.05)'
        $("#kdock-#{kdock.api_id}-remaining").css 'background-color', 'rgba(221, 81, 76, 0.05)'
        $("#kdock-#{kdock.api_id}-material").css 'background-color', 'rgba(221, 81, 76, 0.05)'
      when 0
        clearKdock kdock.api_id
        kdockTimer[kdock.api_id] = -1
      when 1 #大建中
        clearKdock kdock.api_id
        $("#kdock-name-#{kdock.api_id}").css 'color', '#DD514C'
        $("#kdock-timer-#{kdock.api_id}").css 'color', '#DD514C'
        $("#kdock-#{kdock.api_id}-name").css 'color', '#DD514C'
        $("#kdock-#{kdock.api_id}-remaining").css 'color', '#DD514C'
        $("#kdock-#{kdock.api_id}-material").css 'color', '#DD514C'
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = Math.floor((kdock.api_complete_time - new Date()) / 1000)
        materialStr = "#{getMaterialImgTag(1)} #{kdock.api_item1} #{getMaterialImgTag(2)} #{kdock.api_item2} #{getMaterialImgTag(3)} #{kdock.api_item3} #{getMaterialImgTag(4)} #{kdock.api_item4} #{getMaterialImgTag(7)} #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").html materialStr
      when 2 #普建中
        clearKdock kdock.api_id
        # 大建
        if kdock.api_item1 > 999 || kdock.api_item2 > 999 || kdock.api_item3 > 999 || kdock.api_item4 > 999
          $("#kdock-name-#{kdock.api_id}").css 'color', '#DD514C'
          $("#kdock-timer-#{kdock.api_id}").css 'color', '#DD514C'
          $("#kdock-#{kdock.api_id}-name").css 'color', '#DD514C'
          $("#kdock-#{kdock.api_id}-remaining").css 'color', '#DD514C'
          $("#kdock-#{kdock.api_id}-material").css 'color', '#DD514C'
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = Math.floor((kdock.api_complete_time - new Date()) / 1000)
        materialStr = "#{getMaterialImgTag(1)} #{kdock.api_item1} #{getMaterialImgTag(2)} #{kdock.api_item2} #{getMaterialImgTag(3)} #{kdock.api_item3} #{getMaterialImgTag(4)} #{kdock.api_item4} #{getMaterialImgTag(7)} #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").html materialStr
      when 3
        $("#kdock-#{kdock.api_id}-name").text ships[kdock.api_created_ship_id].api_name
        $("#kdock-name-#{kdock.api_id}").text ships[kdock.api_created_ship_id].api_name
        kdockTimer[kdock.api_id] = 0
        materialStr = "#{getMaterialImgTag(1)} #{kdock.api_item1} #{getMaterialImgTag(2)} #{kdock.api_item2} #{getMaterialImgTag(3)} #{kdock.api_item3} #{getMaterialImgTag(4)} #{kdock.api_item4} #{getMaterialImgTag(7)} #{kdock.api_item5}"
        $("#kdock-#{kdock.api_id}-material").html materialStr

exports.refreshCreateitem = ->
  switch createItem.api_create_flag
    when 0 #失败
      $('#createitem-state').attr 'class', 'am-btn am-btn-danger'
      $('#createitem-state').text '失败'
      str = createItem.api_fdata
      createItemId = parseInt str.split(',')[1]
      $('#createitem-name').text slotitems[createItemId].api_name
      $('#createitem-state').show()
    when 1 #成功
      $('#createitem-state').attr 'class', 'am-btn am-btn-success'
      $('#createitem-state').text '成功'
      $('#createitem-name').text slotitems[createItem.api_slot_item.api_slotitem_id].api_name
      $('#createitem-state').show()

exports.refreshExperience = ->
  list = []
  for ship in ownShips
    list.push ship if ship
  list.sort (a, b) ->
    return b.api_exp[0] - a.api_exp[0]
  html = '<option value=",,">下拉列表选择舰娘</option>'
  for ship in list
    nextLv = 150
    if ship.api_lv < 99
      nextLv = 99
    if ships[ship.api_ship_id].api_afterlv != 0 && ships[ship.api_ship_id].api_afterlv > ship.api_lv
      nextLv = Math.min nextLv, ships[ship.api_ship_id].api_afterlv
    html += "<option value=\"#{ship.api_lv},#{ship.api_exp[1]},#{nextLv}\">Lv. #{ship.api_lv} - #{ships[ship.api_ship_id].api_name}</option>"
  $('#exp-ship').html html

exports.calcExperience = ->
  nowExp = exp[parseInt($('#exp-lv').val()) + 1] - parseInt($('#exp-next').val())
  goalExp = exp[parseInt $('#exp-goal').val()]
  deltaExp = 0
  if goalExp > nowExp
    deltaExp = goalExp - nowExp
  mapExp = parseInt($('#exp-map').val()) * parseFloat($('#exp-result').val())
  html = "<ul style=\"text-align: left;\"><li>达到等级需要经验: #{deltaExp}</li>"
  html += "<li>基本: #{mapExp} 需#{Math.ceil((deltaExp / mapExp))}场</li>"
  html += "<li>旗舰: #{mapExp * 1.5} 需#{Math.ceil((deltaExp / mapExp / 1.5))}场</li>"
  html += "<li>MVP: #{mapExp * 2.0} 需#{Math.ceil((deltaExp / mapExp / 2.0))}场</li>"
  html += "<li>旗舰MVP: #{mapExp * 3.0} 需#{Math.ceil((deltaExp / mapExp / 3.0))}场</li></ul>"
  exports.showModalHtml '经验计算', html
