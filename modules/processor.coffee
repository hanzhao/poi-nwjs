ui = require('./ui')
util = require('./util')
url = require('url')
fs = require('fs')
path = require('path')

isRecordAPIOpen = false

exports.processData = (req, data) ->
  ui.turnOn()
  data = data.toString()
  data = data.substring(7) if data.indexOf('svdata=') == 0
  try
    data = JSON.parse data
  catch
    return
  # Record API Information
  if isRecordAPIOpen
    filePath = url.parse(req.url).pathname.substr 1
    util.guaranteeFilePath filePath
    d = JSON.stringify data, null, 2
    fs.appendFile "#{filePath}.json", "Url: #{req.url}\nMethod: #{req.method}\nPostData: #{req.postData}\nReceiveData: #{d}\n\n\n", (err) ->
      console.log err if err?
  return unless data.api_result == 1
  position = url.parse(req.url).pathname.replace '/kcsapi', ''
  switch position
    when '/api_start2'
      ui.updateGameData data.api_data
    when '/api_get_member/basic'
      ui.updateUserData data.api_data
      ui.refreshUser()
    when '/api_get_member/slot_item'
      ui.updateSlotitemData data.api_data
    when '/api_port/port'
      ui.updatePortData data.api_data
      ui.refreshMaterials()
      ui.refreshDecks()
      ui.refreshNdocks()
    when '/api_get_member/kdock'
      ui.updateKdocksData data.api_data
      ui.refreshKdocks()
    when '/api_req_kousyou/createitem'
      ui.updateCreateitemData data.api_data
      ui.refreshCreateitem()
    # when '/api_req_kousyou/getship'
      # ui.updateKdocksDataInGetship data.api_data
      # ui.refreshKdocks
