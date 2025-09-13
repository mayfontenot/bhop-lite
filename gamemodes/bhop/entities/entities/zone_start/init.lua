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

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		local steamID = ent:SteamID64()

		if  ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK and playerCache[steamID].timerStart == 0 then
			playerCache[steamID].timerStart = CurTime()

			NetworkPlayerCache()
		end
	end
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		if  ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK then
			local steamID = ent:SteamID64()
			ent.groundTicks = (ent:OnGround() and ent.groundTicks) and ent.groundTicks + 1 or 0

			if not ent:OnGround() and playerCache[steamID].timerStart == 0 then
				playerCache[steamID].timerStart = CurTime()

				NetworkPlayerCache()
			elseif ent.groundTicks >= 15 and playerCache[steamID].timerStart > 0 then
				playerCache[steamID].timerStart = 0

				NetworkPlayerCache()
			end
		end
	end
end