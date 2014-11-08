exports.updateNdocks = (api_ndock_port) ->
	ndocks = []
	for ndock in api_ndock_port
		ndocks[ndock.api_id] = ndock
		if ndocks[ndock.api_id].api_state == -1
			$("#ndock-#{ndocks.api_id}-open").text "被锁定"
			$("#ndock-#{ndocks.api_id}-name").text ""
			$("#ndock-#{ndocks.api_id}-endtime").text ""
			$("#ndock-#{ndocks.api_id}-resttime").text ""
		if ndocks[ndock.api_id].api_state == 0
			$("#ndock-#{ndocks.api_id}-open").text "未使用"
			$("#ndock-#{ndocks.api_id}-name").text ""
			$("#ndock-#{ndocks.api_id}-endtime").text ""
			$("#ndock-#{ndocks.api_id}-resttime").text ""
		if ndocks[ndock.api_id].api_state == 1
			ship = ownShips[ndock.api_ship_id]
			$("#ndock-#{ndocks.api_id}-open").text ndock.api_id
			$("#ndock-#{ndocks.api_id}-name").text ships[ship.api_ship_id].api_name
			$("#ndock-#{ndocks.api_id}-endtime").text ndock.api_complete_time_str
			$("#ndock-#{ndocks.api_id}-resttime").text ""