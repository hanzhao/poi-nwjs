$ = global.$

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

exports.updateShips = (api_mst_ship) ->
  ships = []
  ships[ship.api_id] = ship for ship in api_mst_ship

exports.updateShiptypes = (api_mst_stype) ->
  stypes = []
  stypes[stype.api_id] = stype for stype in api_mst_stype

exports.updateSlotitems = (api_mst_slotitem) ->
  slotitems = []
  slotitems[slotitem.api_id] = slotitem for slotitem in api_mst_slotitem

exports.updateMapareas = (api_mst_maparea) ->
  mapareas = []
  mapareas[maparea.api_id] = maparea for maparea in api_mst_maparea

exports.updateMaps = (api_mst_mapinfo) ->
  maps = []
  maps[map.api_id] = map for map in api_mst_mapinfo

exports.updateMissions = (api_mst_mission) ->
  missions = []
  missions[mission.api_id] = mission for mission in api_mst_mission

exports.updateOwnSlotitems = (api_slotitem) ->
  ownSlotitems = []
  ownSlotitems[slotitem.api_id] = slotitem for slotitem in api_slotitem

exports.updateOwnShips = (api_ship) ->
  ownShips = []
  ownShips[ship.api_id] = ship for ship in api_ship

exports.updateMaterials = (api_material) ->
  material = []
  materials[material.api_id] = material for material in api_material

exports.updateDecks = (api_deck_port) ->
  decks = []
  decks[deck.api_id] = deck for deck in api_deck_port
