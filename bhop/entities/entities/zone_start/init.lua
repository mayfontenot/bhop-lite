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
	if IsValid(ent) and ent:IsPlayer() then
		local steamID = ent:SteamID64()

		if  ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK and tempCache[steamID].timer_start == 0 then
			tempCache[steamID].timer_start = CurTime()

			UpdateTempCache()
		end
	end
end

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() then
		if  ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK then
			local steamID = ent:SteamID64()
			ent.groundTicks = (ent:OnGround() and ent.groundTicks) and ent.groundTicks + 1 or 0

			if not ent:OnGround() and tempCache[steamID].timer_start == 0 then
				tempCache[steamID].timer_start = CurTime()

				UpdateTempCache()
			elseif ent.groundTicks >= 15 and tempCache[steamID].timer_start > 0 then
				tempCache[steamID].timer_start = 0

				UpdateTempCache()
			end
		end
	end
end