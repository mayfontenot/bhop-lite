AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_cache.lua")
AddCSLuaFile("sh_movement.lua")
AddCSLuaFile("sh_rngfix.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_cache.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_menu.lua")

include("shared.lua")
include("sh_cache.lua")
include("sh_movement.lua")
include("sh_rngfix.lua")
include("sv_cache.lua")
include("sv_movement.lua")
include("sv_commands.lua")

function ChangeLevel(map)
	PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] Changing level to " .. map .. " in 5 seconds, expect lag")
	WriteToJSON()

	timer.Simple(5, function()
		RunConsoleCommand("changelevel", map)
	end)
end

startZone, endZone = nil, nil

function GM:Initialize()
	startZone, endZone = ents.Create("zone_start"), ents.Create("zone_end")

	ReadFromJSON()
end

function GM:OnEntityCreated(ent)			--fix for maps potentially containing backdoors
	if ent:GetClass() == "lua_run" then
		ent:Remove()

		print("!CAUTIONi Map contains a potential back door iCAUTION!")
	end
end

local spawns = {}

function GM:InitPostEntity()
	for _, v in pairs(ents.FindByClass("func_button")) do 		--blocks fix
		v:Fire("Lock")
		v:SetKeyValue("locked_sound", 0)
	end

	for _, v in pairs(ents.FindByClass("func_door")) do
		v:Fire("Lock")
		v:SetKeyValue("locked_sound", 0)
	end

	spawns = ents.FindByClass("info_player_start")

	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_counterterrorist")
	end

	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_terrorist")
	end

	RunConsoleCommand("bot")
end

function GM:PlayerSelectSpawn(ply, transition)
	return spawns[math.random(#spawns)]
end

function GM:PlayerInitialSpawn(ply)
	ply:SetModel(models[math.random(#models)])
	ply:SetTeam(TEAM_PLAYER)

	UpdateTempPlayerCache(ply) --here we only send cache to the player that connected instead of broadcasting to all players, because other players have these caches already
	UpdatePlayerCache(ply)
	UpdatePersonalRecordsCache(ply)
	UpdateWorldRecordsCache(ply)
	UpdateMapCache(ply)
	UpdateMapsCache(ply)

	ply:SetNoCollideWithTeammates(true)
	ply:SetAvoidPlayers(false)
	ply:SetWalkSpeed(250)
	ply:SetRunSpeed(250)
	ply:SetStepSize(18)
	ply:SetJumpPower(290)
	ply:SetCrouchedWalkSpeed(0.6)

	ply:SetDuckSpeed(0.4)
	ply:SetUnDuckSpeed(0.2)

	ply:SetHull(Vector(-16, -16, 0), Vector(16, 16, 62))
	ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 45))

	ply:SetViewOffset(Vector(0, 0, 64))
	ply:SetViewOffsetDucked(Vector(0, 0, 47))
end

function GM:PlayerSpawn(ply, transition)
	ply:StripWeapons()
end

function GM:EntityFireBullets(ent, data)				--refill the magazine when player shoots
	local activeWeapon = ent:GetActiveWeapon()

	activeWeapon:SetClip1(activeWeapon:GetMaxClip1())

	return true
end

function GM:PlayerNoClip(ply)										--disable timer if player noclips
	WriteToCache(tempPlayerCache, 0, ply:SteamID(), "timerStart")
	UpdateTempPlayerCache()

	return true
end

function GM:ShowHelp(ply)
	ply:ConCommand("bhoplite_menu")
end

function GM:PlayerUse(ply)
	return ply:Team() ~= TEAM_SPECTATOR
end

function GM:IsSpawnpointSuitable(ply, spawnPoint, makeSuitable)
	return true
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
	return true
end

--disable unwanted features
function GM:GetFallDamage(ply, speed)
	return false
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	return false
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:PlayerSpray(sprayer)
	return true
end

function GM:AllowPlayerPickup(ply, ent)
	return false
end