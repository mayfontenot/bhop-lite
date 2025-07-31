function EndTimer(ply, timerEnd)
	local steamID, name = ply:SteamID(), ply:Name()
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
	local time = timerEnd - ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
	local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
	local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)

	if time < worldRecord or worldRecord == 0 then
		WriteToCache(worldRecordsCache, {["steamID"] = steamID, ["name"] = name, ["time"] = time}, style)
		WriteToCache(personalRecordsCache, time, steamID, style)
		UpdatePersonalRecordsCache()
		UpdateWorldRecordsCache()

		local diff = worldRecord > 0 and " s (" .. ConvertTime(time - worldRecord) .. " s)" or ""

		PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " set a new " .. style .. " World Record of " .. ConvertTime(time) .. diff)
	elseif time < personalRecord or personalRecord == 0 then
		WriteToCache(personalRecordsCache, time, steamID, style)
		UpdatePersonalRecordsCache()

		local diff = personalRecord > 0 and " s (" .. ConvertTime(time - personalRecord) .. " s)" or ""

		PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " finished " .. style .. " in " .. ConvertTime(time) .. diff)
	else
		ply:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] You did not beat your Personal Record (+" .. ConvertTime(' .. time - personalRecord .. ') .. " s)")')
	end
end