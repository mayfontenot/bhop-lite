GM.Name = "Bunny Hop"
GM.Author = "Mei"
GM.Website = "meiware.net"
GM.TeamBased = false

DeriveGamemode("base")

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

math.randomseed(os.time())

function GM:CreateTeams()
	team.SetUp(TEAM_SPECTATOR, "Spectator", Color(125, 125, 125))
	team.SetUp(TEAM_PLAYER, "Normal", Color(200, 200, 200))
end