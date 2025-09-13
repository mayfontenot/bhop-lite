--cache commonly used methods and constants, these are not precached by the lua engine
util = util
util.PrecacheModel = util.PrecacheModel
util.AddNetworkString = util.AddNetworkString
math = math
math.abs = math.abs
math.randomseed = math.randomseed
math.random = math.random
math.floor = math.floor
math.Clamp = math.Clamp
math.Round = math.Round
os = os
os.time = os.time
string = string
string.format = string.format
string.lower = string.lower
string.sub = string.sub
string.StartsWith = string.StartsWith
table = table
table.KeyFromValue = table.KeyFromValue
ents = ents
ents.FindByClass = ents.FindByClass
player = player
player.GetAll = player.GetAll
ents.Create = ents.Create
team = team
team.SetUp = team.SetUp
game = game
game.GetMap = game.GetMap
net = net
net.Start = net.Start
net.WriteTable = net.WriteTable
net.Broadcast = net.Broadcast
net.Send = net.Send
net.Receive = net.Receive
net.ReadTable = net.ReadTable
bit = bit
bit.band = bit.band
bit.bnot = bit.bnot
Color = Color
Vector = Vector
FrameTime = FrameTime
CurTime = CurTime
GetHostName = GetHostName
ScrW = ScrW
ScrH = ScrH
LocalPlayer = LocalPlayer
IsValid = IsValid
pairs = pairs
ipairs = ipairs
PrintMessage = PrintMessage
HUD_PRINTTALK = HUD_PRINTTALK
MOVETYPE_WALK = MOVETYPE_WALK
MOVETYPE_NONE = MOVETYPE_NONE
RENDERMODE_NONE = RENDERMODE_NONE
IN_ATTACK = IN_ATTACK
IN_ATTACK2 = IN_ATTACK2
IN_JUMP = IN_JUMP

playerCache = {} --stores timerStart and style to [steam_id], networked
recordsCache = {} --stores name and time to [steam_id], networked
replayCache = {} --stores replay to [steam_id], not networked
roleCache = {} --stores role to [steam_id], not networked

function ReadFromCache(cache, fallBack, ...) -- ... represents an infinite number of nested keys, you can index the table for as many nested keys as the table has
	for _, v in ipairs({...}) do
		if cache[v] then
			cache = cache[v]
		else
			return fallBack
		end
	end

	return cache
end

for _, v in pairs(MODELS) do 	--cache playermodels
	util.PrecacheModel(v)
end