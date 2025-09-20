AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local function MaxVector(tbl)
	local max = tbl[1]

	for _, v in pairs(tbl) do
		if v:Length2DSqr() > max:Length2DSqr() then
			max = v
		end
	end

	return max
end

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionBounds(self.boundsMin, self.boundsMax)
	self:SetNotSolid(true)
	self:SetTrigger(true) --necessary for Touch
	self:DrawShadow(false)
end

function ENT:EndTouch(ent)
	local destination = ents.FindByName(self:GetInternalVariable("target"))[1]

	if destination then
		if mapCache.telehopFixType or 0 == 0 then
			if ent:IsPlayer() then
				if not ent:IsBot() then
					local vel = MaxVector(ent.velStack)
					vel:Rotate(Angle(0, destination:GetAngles().y - vel:Angle().y, 0))

					ent:SetVelocity(vel - ent:GetVelocity())
				end
			else
				local vel = ent:GetVelocity()
				vel:Rotate(Angle(0, destination:GetAngles().y - vel:Angle().y, 0))

				ent:SetVelocity(vel)
			end
		end
	end
end