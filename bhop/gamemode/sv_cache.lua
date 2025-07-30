util.AddNetworkString("tempPlayerCacheUpdate")
util.AddNetworkString("playerCacheUpdate")
util.AddNetworkString("personalRecordsCacheUpdate")
util.AddNetworkString("worldRecordsCacheUpdate")
util.AddNetworkString("mapCacheUpdate")

function WriteToJSON()
	file.CreateDir("bhop")
	file.Write("bhop/player.json", util.TableToJSON(playerCache, true))
	file.Write("bhop/" .. game.GetMap() .. ".json", util.TableToJSON({["personalRecords"] = personalRecordsCache, ["worldRecords"] = worldRecordsCache, ["map"] = mapCache}, true))
end

function ReadFromJSON()
	playerCache = file.Exists("bhop/player.json", "DATA") and util.JSONToTable(file.Read("bhop/player.json", "DATA"), false, true) or {}
	local map = game.GetMap()
	local tempCache = file.Exists("bhop/" .. map .. ".json", "DATA") and util.JSONToTable(file.Read("bhop/" .. map .. ".json", "DATA"), false, true) or {}
	personalRecordsCache = ReadFromCache(tempCache, {}, "personalRecords")
	worldRecordsCache = ReadFromCache(tempCache, {}, "worldRecords")
	mapCache = ReadFromCache(tempCache, {}, "map")

	playerCache = {						--add your steamID here
		["STEAM_0:0:623003536"] = {
			["role"] = "Admin", 
		}
	}

	startZone:SetPos(Vector(ReadFromCache(mapCache, 0, "startX"), ReadFromCache(mapCache, 0, "startY"), ReadFromCache(mapCache, 0, "startZ")))
	endZone:SetPos(Vector(ReadFromCache(mapCache, 0, "endX"), ReadFromCache(mapCache, 0, "endY"), ReadFromCache(mapCache, 0, "endZ")))

	startZone.size = Vector(ReadFromCache(mapCache, 0, "startL"), ReadFromCache(mapCache, 0, "startW"), ReadFromCache(mapCache, 0, "startH"))
	endZone.size = Vector(ReadFromCache(mapCache, 0, "endL"), ReadFromCache(mapCache, 0, "endW"), ReadFromCache(mapCache, 0, "endH"))

	startZone:Spawn()
	endZone:Spawn()
end

function WriteToCache(cache, value, ...) -- ... represents an infinite number of indices, you can index the cache for as many indices as the cache table allows
	local indices = {...}
	local tempCache = cache

    for i = 1, #indices - 1 do
        local key = indices[i]

        if not tempCache[key] then
            tempCache[key] = {}
        end

        tempCache = tempCache[key]
    end

    tempCache[indices[#indices]] = value
end

function UpdateTempPlayerCache(ply)
	local ply = ply or nil

	net.Start("tempPlayerCacheUpdate")
	net.WriteTable(tempPlayerCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function UpdatePlayerCache(ply)
	local ply = ply or nil

	net.Start("playerCacheUpdate")
	net.WriteTable(playerCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function UpdatePersonalRecordsCache(ply)
	local ply = ply or nil

	net.Start("personalRecordsCacheUpdate")
	net.WriteTable(personalRecordsCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function UpdateWorldRecordsCache(ply)
	local ply = ply or nil

	net.Start("worldRecordsCacheUpdate")
	net.WriteTable(worldRecordsCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end

function UpdateMapCache(ply)
	local ply = ply or nil

	net.Start("mapCacheUpdate")
	net.WriteTable(mapCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end