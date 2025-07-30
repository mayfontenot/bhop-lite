local function ChangeStyle(ply, newStyle)
	local steamID = ply:SteamID()

	if ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style") ~= newStyle then
		ply:Spawn()

		WriteToCache(tempPlayerCache, newStyle, steamID, "style")
		UpdateTempPlayerCache()
	end
end

local function UpdateZone(pos2, zone)
	local ent = zone == "start" and startZone or endZone
	local pos = Vector((ent.pos1.x + pos2.x) / 2, (ent.pos1.y + pos2.y) / 2, (ent.pos1.z + pos2.z) / 2)
	local size = Vector(math.abs(pos2.x - ent.pos1.x), math.abs(pos2.y - ent.pos1.y), math.abs(pos2.z - ent.pos1.z))

	WriteToCache(mapCache, pos.x, zone .. "X")
	WriteToCache(mapCache, pos.y, zone .. "Y")
	WriteToCache(mapCache, pos.z, zone .. "Z")
	WriteToCache(mapCache, size.x, zone .. "L")
	WriteToCache(mapCache, size.y, zone .. "W")
	WriteToCache(mapCache, size.z, zone .. "H")

	ent:SetPos(pos)
	ent.size = size
	ent:Spawn()
end

function GM:PlayerSay(sender, text, teamChat)
	text = string.lower(text)

	if text[1] == "!" or text[1] == "/" then
		text = string.sub(text, 2)

		if text == "restart" or text == "r" then
			sender:Spawn()
		end

		if text == "usp" then
			sender:Give("weapon_usp")
		end

		if text == "glock" then
			sender:Give("weapon_glock")
		end

		if text == "remove" then
			sender:StripWeapons()
		end

		if text == "auto" or text == "normal" or text == "n" then
			ChangeStyle(sender, STYLE_AUTO)
		end

		if text == "manual" or text == "easy" or text == "legit" then
			ChangeStyle(sender, STYLE_MANUAL)
		end

		if text == "sideways" or text == "sw" then
			ChangeStyle(sender, STYLE_SIDEWAYS)
		end

		if text == "halfsideways" or text == "hsw" then
			ChangeStyle(sender, STYLE_HALF_SIDEWAYS)
		end

		if text == "wonly" or text == "w" then
			ChangeStyle(sender, STYLE_W_ONLY)
		end

		if text == "aonly" or text == "a" then
			ChangeStyle(sender, STYLE_A_ONLY)
		end

		if text == "spectate" or text == "spec" then
			if sender:Team() == TEAM_SPECTATOR then
				sender:SetTeam(TEAM_PLAYER)
				sender:UnSpectate()
				sender:Spawn()
			else
				sender:SetTeam(TEAM_SPECTATOR)
				sender:Spectate(OBS_MODE_IN_EYE)
			end
		end

		if string.StartsWith(text, "tier ") then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				local tier = string.sub(text, 6)

				WriteToCache(mapCache, tier, "tier")
				UpdateMapCache()
			end
		end

		if text == "start pos1" then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				startZone.pos1 = sender:GetPos()
			end
		end

		if text == "end pos1" then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				endZone.pos1 = sender:GetPos()
			end
		end

		if text == "start pos2" then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				UpdateZone(sender:EyePos(), "start")
			end
		end

		if text == "end pos2" then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				UpdateZone(sender:EyePos(), "end")
			end
		end

		if text == "save" then
			if ReadFromCache(playerCache, ROLE_USER, sender:SteamID(), "role") == ROLE_ADMIN then
				WriteToJSON()
			end
		end

		return ""
	end

	return text
end
