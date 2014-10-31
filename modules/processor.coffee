ui = require('./ui')
url = require('url')

exports.processData = (req, data) ->
  data = data.toString()
  data = data.substring(7) if data.indexOf('/svdata=') == 0
  data = JSON.parse data
  position = url.parse(req.url).pathname.replace '/kcsapi', ''
  switch position
    when '/api_start2'
      updateGameData req, data
    when '/api_get_member/slot_item'
      updateSlotitemData req, data
    when '/api_port/port'
      updatePortData req, data

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
