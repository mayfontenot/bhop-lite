ALT_NAME = "BHop Lite"
TEAM_SPECTATOR, TEAM_PLAYER = 1, 2
STYLE_AUTO, STYLE_MANUAL, STYLE_SIDEWAYS, STYLE_HALF_SIDEWAYS, STYLE_W_ONLY, STYLE_A_ONLY = "Auto", "Manual", "Sideways", "Half-sideways", "W-only", "A-only"
ROLE_USER, ROLE_MOD, ROLE_ADMIN = "User", "Mod", "Admin"
models = {
	"models/player/gasmask.mdl", 
	"models/player/riot.mdl", 
	"models/player/swat.mdl", 
	"models/player/urban.mdl", 
	"models/player/arctic.mdl", 
	"models/player/guerilla.mdl", 
	"models/player/leet.mdl", 
	"models/player/phoenix.mdl"
}

include("sh_cache.lua")
include("sh_movement.lua")
include("sh_timer.lua")

GM.Name = "Bunny Hop"
GM.Author = "Mei"
GM.Website = "meiware.net"
GM.TeamBased = false

DeriveGamemode("base")

math.randomseed(os.time())

function GM:CreateTeams()
	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(150, 150, 150))
	team.SetUp(TEAM_PLAYER, "Normal", Color(255, 255, 255))
end