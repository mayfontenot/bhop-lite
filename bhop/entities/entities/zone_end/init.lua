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
			if ReadFromCache(tempPlayerCache, 0, ent:SteamID(), "timerStart") > 0 then
				EndTimer(ent, CurTime())
			end
		end
	end
end