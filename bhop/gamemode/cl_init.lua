include("shared.lua")
include("sh_cache.lua")
include("sh_movement.lua")
include("sh_rngfix.lua")
include("cl_cache.lua")
include("cl_hud.lua")

function GM:InitPostEntity()
	local ply = LocalPlayer()

	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))

	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 47))
end