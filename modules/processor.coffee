ui = require('./ui')
util = require('./util')
url = require('url')
fs = require('fs')
path = require('path')
querystring = require('querystring')

isRecordAPIOpen = false

exports.processData = (req, data) ->
  ui.turnOn()
  data = data.toString()
  data = data.substring(7) if data.indexOf('svdata=') == 0
  try
    data = JSON.parse data
    req.postData = querystring.parse req.postData
  catch
    return
  # Record API Information
  if isRecordAPIOpen
    filePath = url.parse(req.url).pathname.substr 1
    filePath = "#{global.appDataPath}/#{filePath}"
    d = JSON.stringify data, null, 2
    util.guaranteeFilePath filePath
    fs.appendFile "#{filePath}.json", "Url: #{req.url}\nMethod: #{req.method}\nPostData: #{JSON.stringify req.postData, null, 2}\nReceiveData: #{d}\n\n\n", (err) ->
      console.log err if err?
  return unless data.api_result == 1
  position = url.parse(req.url).pathname.replace '/kcsapi', ''
  switch position
    when '/api_start2'
      ui.api_start2 data.api_data
    when '/api_get_member/basic'
      ui.api_get_member_basic data.api_data
      ui.refreshUser()
    when '/api_get_member/ship2'
      ui.api_get_member_ship2 data
      ui.refreshDecks()
    when '/api_get_member/slot_item'
      ui.api_get_member_slot_item data.api_data
    when '/api_port/port'
      ui.api_port_port data.api_data
      ui.refreshMaterials()
      ui.refreshDecks()
      ui.refreshNdocks()
    when '/api_get_member/kdock'
      ui.api_get_member_kdock data.api_data
      ui.refreshKdocks()
    when '/api_req_hokyu/charge'
      ui.api_req_hokyu_charge data.api_data
      ui.refreshDecks()
    when '/api_req_kousyou/createitem'
      ui.api_req_kousyou_createitem data.api_data
      ui.refreshCreateitem()
    when '/api_req_kousyou/getship'
      ui.api_req_kousyou_getship data.api_data
      ui.refreshKdocks()
    when '/api_req_mission/start'
      ui.api_req_mission_start req.postData, data.api_data
      ui.refreshDecks()
