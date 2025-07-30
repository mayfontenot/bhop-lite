function EndTimer(ply, timerEnd)
	local steamID, name = ply:SteamID(), ply:Name()
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
	local time = timerEnd - ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
	local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
	local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)

	if time < worldRecord or worldRecord == 0 then
		WriteToCache(worldRecordsCache, {["steamID"] = steamID, ["name"] = name, ["time"] = time}, style)
		WriteToCache(personalRecordsCache, time, steamID, style)
		WriteToCache(playerCache, ReadFromCache(mapCache, 1, "tier") * 100, steamID, "points")
		UpdatePersonalRecordsCache()
		UpdateWorldRecordsCache()

		PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " set a new " .. style .. " World Record of " .. ConvertTime(time) .. "!")
	elseif time < personalRecord or personalRecord == 0 then
		WriteToCache(personalRecordsCache, time, steamID, style)
		WriteToCache(playerCache, ReadFromCache(mapCache, 1, "tier") * 100, steamID, "points")
		UpdatePersonalRecordsCache()

		PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " finished " .. style .. " in " .. ConvertTime(time) .. ".")
	end
end