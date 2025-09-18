AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_cache.lua")
AddCSLuaFile("sh_movement.lua")
AddCSLuaFile("sh_rngfix.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_cache.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_menu.lua")

include("shared.lua")
include("sh_cache.lua")
include("sh_movement.lua")
include("sh_rngfix.lua")
include("sv_cache.lua")
include("sv_network.lua")
include("sv_movement.lua")

function ChangeLevel(map)
	PrintMessage(HUD_PRINTTALK, "[" .. ALT_NAME .. "] Changing level to " .. map .. " in 5 seconds, expect lag")

	timer.Simple(5, function()
		WriteCacheToDB()
		RunConsoleCommand("changelevel", map)
	end)
end

function GM:OnEntityCreated(ent)			--fix for maps potentially containing backdoors
	if ent:GetClass() == "lua_run" then
		ent:Remove()

		print("!CAUTIONi Map contains a potential back door iCAUTION!")
	end
end

startZone, endZone = nil, nil
local spawns = {}

function GM:InitPostEntity()
	startZone, endZone = ents.Create("zone_start"), ents.Create("zone_end")

	ReadCacheFromDB()

	for _, v in pairs(ents.FindByClass("func_door")) do 		--part of doors fix
		v:Fire("Open")
		v:Fire("Lock")
		v:SetKeyValue("locked_sound", 0)
	end

	for _, v in pairs(ents.FindByClass("func_breakable")) do 	--breakable fix
		v:Fire("Break")
	end

	for _, v in pairs(ents.FindByClass("trigger_teleport")) do 	--part of telehop fix
		local ent = ents.Create("trigger_teleport2")
		ent:SetPos(v:GetPos())
		ent:SetAngles(v:GetAngles())
		ent:SetKeyValue("target", v:GetInternalVariable("target"))
		ent.boundsMin = v:GetCollisionBounds()
		ent.boundsMax = select(2, v:GetCollisionBounds())
		ent:Spawn()
	end

	spawns = ents.FindByClass("info_player_start")			--find valid player spawns

	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_counterterrorist")
	end

	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_terrorist")
	end

	RunConsoleCommand("bot")
end

function GM:AcceptInput(ent, input, activator, caller, value)
	if (ent:GetClass() == "func_door" and input == "Close") or ent:GetClass() == "lua_run" then return true end --part of doors fix, and lua_run backdoor fix
end

function GM:PlayerSelectSpawn(ply, transition)
	return spawns[math.random(#spawns)]
end

function GM:PlayerInitialSpawn(ply)
	ply:SetModel(MODELS[math.random(#MODELS)])
	ply:DrawShadow(false)
	ply:SetTeam(TEAM_PLAYER)

	playerCache[ply:SteamID64()] = {style = STYLE_AUTO, timerStart = 0}

	NetworkPlayerCache()
	NetworkRecordsCache()

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

function GM:PlayerNoClip(ply)	--disable timer if player noclips
	playerCache[ply:SteamID64()].timerStart = -1

	NetworkPlayerCache()

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