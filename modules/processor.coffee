ui = require('./ui')
url = require('url')
fs = require('fs')
path = require('path')

bRecordAPI = false

exports.processData = (req, data) ->
  ui.turnOn()
  data = data.toString()
  ############################
  # Record API Information
  if (bRecordAPI)
    filePath = url.parse(req.url).pathname.substr 1
    fileDir = path.dirname filePath
    fs.mkdir fileDir, (err) ->
      console.log err if err?
      d = JSON.stringify(data)
      fs.appendFile "#{filePath}.log", "Url: #{req.url}\nMethod: #{req.method}\nPostData: #{req.postData}\nReceiveData: #{d}\n\n\n", (err) ->
        console.log err if err?
  ############################
  data = data.substring(7) if data.indexOf('svdata=') == 0
  data = JSON.parse data
  position = url.parse(req.url).pathname.replace '/kcsapi', ''
  switch position
    when '/api_get_member/basic'
      updateUserData req, data
    when '/api_start2'
      updateGameData req, data
    when '/api_get_member/slot_item'
      updateSlotitemData req, data
    when '/api_port/port'
      updatePortData req, data
    when '/api_get_member/kdock'
      updateKdockData req, data
    when '/api_req_kousyou/getship'
      updateKdockDataInGetship req, data

updateUserData = (req, data) ->
  return unless data.api_result == 1
  ui.updateUserinfo data.api_data

updateGameData = (req, data) ->
  return unless data.api_result == 1
  ui.updateShips data.api_data.api_mst_ship
  ui.updateShiptypes data.api_data.api_mst_stype
  ui.updateSlotitems data.api_data.api_mst_slotitem
  ui.updateMapareas data.api_data.api_mst_maparea
  ui.updateMaps data.api_data.api_mst_mapinfo
  ui.updateMissions data.api_data.api_mst_mission

updateSlotitemData = (req, data) ->
  return unless data.api_result == 1
  ui.updateOwnSlotitems data.api_data

updatePortData = (req, data) ->
  return unless data.api_result == 1
  ui.updateMaterials data.api_data.api_material
  ui.updateOwnShips data.api_data.api_ship
  ui.updateDecks data.api_data.api_deck_port
  ui.updateNdocks data.api_data.api_ndock

updateKdockData = (req, data) ->
  return unless data.api_result == 1
  ui.updateKdocks data.api_data

updateKdockDataInGetship = (req, data) ->
  return unless data.api_result == 1
  ui.updateKdocks data.api_data.api_kdock