AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	local min, max = Vector(-self.size.x / 2, -self.size.y / 2, -self.size.z / 2), Vector(self.size.x / 2, self.size.y / 2, self.size.z / 2)

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionBounds(min, max)
	self:SetNotSolid(true)
	self:SetTrigger(true) --necessary for Touch
	self:DrawShadow(false)
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() then
		if not ent:IsBot() and ent:Team() ~= TEAM_SPECTATOR then
			local steamID = ent:SteamID64()
			local timerStart = playerCache[steamID].timerStart

			if timerStart > 0 then
				local time = CurTime() - timerStart
				local name = ent:Name()
				local style = playerCache[steamID].style
				local personalRecord = ReadFromCache(recordsCache, 0, style, steamID, "time")
				local worldRecord = ReadFromCache(recordsCache, 0, style, 1, "time")

				if time < worldRecord or worldRecord == 0 then
					WriteToCache(recordsCache, {name = name, time = time}, style, steamID)
					WriteToCache(recordsCache, {steam_id = steamID, name = name, time = time}, style, 1)
					NetworkRecordsCache()

					replayCache[style] = ent.replayCache

					local diff = worldRecord > 0 and " (-" .. FormatRecord(worldRecord - time) .. ")" or ""

					PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " set a new " .. style .. " World Record of " .. FormatRecord(time) .. diff)
				elseif time < personalRecord or personalRecord == 0 then
					WriteToCache(recordsCache, {name = name, time = time}, style, steamID)
					NetworkRecordsCache()

					local diff = personalRecord > 0 and " (-" .. FormatRecord(personalRecord - time) .. ")" or ""

					PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] " .. name .. " finished " .. style .. " in " .. FormatRecord(time) .. diff)
				else
					ent:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] You did not beat your Personal Record (+" .. FormatRecord(' .. time - personalRecord .. ') .. ")")')
				end

				playerCache[steamID].timerStart = 0

				NetworkPlayerCache()
			end
		end
	end
end