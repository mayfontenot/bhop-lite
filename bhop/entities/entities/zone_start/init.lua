AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	local min, max = Vector(-self.size.x / 2, -self.size.y / 2, -self.size.z / 2), Vector(self.size.x / 2, self.size.y / 2, self.size.z / 2)

	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionBounds(min, max)
	self:SetNotSolid(true)
	self:SetTrigger(true) --necessary for StartTouch
	self:DrawShadow(false)
end

function ENT:StartTouch(ent)
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR then
			WriteToCache(tempPlayerCache, 0, ent:SteamID(), "timerStart")
			UpdateTempPlayerCache()
		end
	end
end

function ENT:EndTouch(ent)
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Team() ~= TEAM_SPECTATOR and ent:GetMoveType() == MOVETYPE_WALK and ent:GetVelocity():Length2D() <= 280 then
			WriteToCache(tempPlayerCache, CurTime(), ent:SteamID(), "timerStart")
			UpdateTempPlayerCache()
		end
	end
end