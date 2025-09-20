util.AddNetworkString("replayStyleMessage")
util.AddNetworkString("styleMessage")
util.AddNetworkString("restartMessage")
util.AddNetworkString("weaponMessage")
util.AddNetworkString("spectateMessage")
util.AddNetworkString("adminMapMessage")
util.AddNetworkString("adminZoneMessage")
util.AddNetworkString("adminDeleteRecordMessage")
util.AddNetworkString("adminTelehopFixMessage")

local function ChangeStyle(ply, style)
	local steamID = ply:SteamID64()

	if playerCache[steamID].style ~= style then
		ply:Spawn()

		playerCache[steamID].style = style

		NetworkPlayerCache()
	end
end

local function UpdateZone(pos2, zone)
	local ent = zone == "start" and startZone or endZone

	pos2.z = pos2.z >= ent.pos1.z + 128 and pos2.z or ent.pos1.z + 128
	local pos = Vector((ent.pos1.x + pos2.x) / 2, (ent.pos1.y + pos2.y) / 2, (ent.pos1.z + pos2.z) / 2)

	local size = Vector(math.abs(pos2.x - ent.pos1.x), math.abs(pos2.y - ent.pos1.y), math.abs(pos2.z - ent.pos1.z))

	ent:SetPos(pos)
	ent.size = size
	ent:Spawn()
end

net.Receive("replayStyleMessage", function(len, ply)
	local newStyle = net.ReadString()
	local bot = team.GetPlayers(TEAM_PLAYER)[1]
	local style = playerCache[bot:SteamID64()].style

	bot.lastStyleChange = bot.lastStyleChange or 0

	if style ~= newStyle and CurTime() > bot.lastStyleChange + 30 then
		bot.lastStyleChange = CurTime()
		bot.replayMV = 1

		ChangeStyle(bot, newStyle)
	end
end)

net.Receive("styleMessage", function(len, ply)
	local newStyle = net.ReadString()
	local style = playerCache[ply:SteamID64()].style

	if style ~= newStyle then
		ChangeStyle(ply, newStyle)
	end
end)

net.Receive("restartMessage", function(len, ply)
	playerCache[ply:SteamID64()].timerStart = 0
	ply.replayCache = {}

	ply:Spawn()

	NetworkPlayerCache()
end)

net.Receive("weaponMessage", function(len, ply)
	local choice = net.ReadUInt(2)

	if choice == 0 then
		ply:Give("weapon_usp")
	elseif choice == 1 then
		ply:Give("weapon_glock")
	elseif choice == 2 then
		ply:Give("weapon_knife")
	elseif choice == 3 then
		ply:StripWeapons()
	end
end)

net.Receive("spectateMessage", function(len, ply)
	if ply:Team() == TEAM_SPECTATOR then
		ply:SetTeam(TEAM_PLAYER)
		ply:Spawn()
		ply:UnSpectate()
	else
		ply.replayCache = {}

		ply:SetTeam(TEAM_SPECTATOR)
		ply:Spawn()
		ply:Spectate(OBS_MODE_IN_EYE)
		ply:SpectateEntity(team.GetPlayers(TEAM_PLAYER)[1])
	end
end)

net.Receive("adminMapMessage", function(len, ply)
	if (roleCache[ply:SteamID64()] or ROLE_USER) == ROLE_ADMIN then
		ChangeLevel(net.ReadString())
	end
end)

net.Receive("adminZoneMessage", function(len, ply)
	if (roleCache[ply:SteamID64()] or ROLE_USER) == ROLE_ADMIN then
		local choice1, choice2 = net.ReadBit(), net.ReadBit()

		if choice1 == 0 then
			if choice2 == 0 then
				startZone.pos1 = ply:GetPos()
			elseif choice2 == 1 then
				UpdateZone(ply:EyePos(), "start")
			end
		elseif choice1 == 1 then
			if choice2 == 0 then
				endZone.pos1 = ply:GetPos()
			elseif choice2 == 1 then
				UpdateZone(ply:EyePos(), "end")
			end
		end
	end
end)

net.Receive("adminDeleteRecordMessage", function(len, ply)
	if (roleCache[ply:SteamID64()] or ROLE_USER) == ROLE_ADMIN then
		local style, steamID = net.ReadString(), net.ReadString()

		recordsCache[style][steamID] = nil
		sql.QueryTyped("DELETE FROM records WHERE map = ? AND style = ? AND steam_id = ?", game.GetMap(), style, steamID)
		sql.QueryTyped("DELETE FROM replays WHERE map = ? AND style = ?", game.GetMap(), style)
	end
end)

net.Receive("adminTelehopFixMessage", function(len, ply)
	if (roleCache[ply:SteamID64()] or ROLE_USER) == ROLE_ADMIN then
		mapCache.telehopFixType = net.ReadBit()
	end
end)