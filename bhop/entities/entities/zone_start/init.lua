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
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK and ReadFromCache(tempPlayerCache, 0, ent:SteamID(), "timerStart") == 0 then
			WriteToCache(tempPlayerCache, CurTime(), ent:SteamID(), "timerStart")
			UpdateTempPlayerCache()
		end
	end
end

function ENT:Touch(ent)
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK then
			if ent:OnGround() then
				ent.groundTicks = ent.groundTicks and ent.groundTicks + 1 or 0
			else
				ent.groundTicks = 0
			end

			if not ent:OnGround() and ReadFromCache(tempPlayerCache, 0, ent:SteamID(), "timerStart") == 0 then
				WriteToCache(tempPlayerCache, CurTime(), ent:SteamID(), "timerStart")
				UpdateTempPlayerCache()
			elseif ent.groundTicks >= 15 and ent:OnGround() and not ent:KeyDown(IN_JUMP) and ReadFromCache(tempPlayerCache, 0, ent:SteamID(), "timerStart") > 0 then
				WriteToCache(tempPlayerCache, 0, ent:SteamID(), "timerStart")
				UpdateTempPlayerCache()
			end
		end
	end
end