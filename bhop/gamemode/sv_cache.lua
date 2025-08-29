util.AddNetworkString("tempCacheUpdate")
util.AddNetworkString("mapCacheUpdate")
util.AddNetworkString("recordsCacheUpdate")

function WriteCacheToDB()
	local map = game.GetMap()

	if table.Count(mapCache) > 0 then
		sql.QueryTyped("INSERT OR REPLACE INTO maps (map, tier, start_x, start_y, start_z, start_l, start_w, start_h, end_x, end_y, end_z, end_l, end_w, end_h) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", map, mapCache.tier, mapCache.start_x, mapCache.start_y, mapCache.start_z, mapCache.start_l, mapCache.start_w, mapCache.start_h, mapCache.end_x, mapCache.end_y, mapCache.end_z, mapCache.end_l, mapCache.end_w, mapCache.end_h)
	end

	for style, record in pairs(recordsCache) do
		for steam_id, v in pairs(record) do
			sql.QueryTyped("INSERT OR REPLACE INTO records (map, style, steam_id, name, time) VALUES (?, ?, ?, ?, ?)", map, style, steam_id, v.name, v.time)
		end
	end

	for style, frames in pairs(replayCache) do
		for frame, v in pairs(frames) do
			sql.QueryTyped("INSERT OR REPLACE INTO replays (map, style, frame, x, y, z, pitch, yaw) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", map, style, frame, v.x, v.y, v.z, v.pitch, v.yaw)
		end
	end

	for steam_id, v in pairs(roleCache) do
		sql.QueryTyped("INSERT OR REPLACE INTO roles (steam_id, role) VALUES (?, ?)", steam_id, v)
	end
end

function ReadCacheFromDB()
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS maps (map TEXT PRIMARY KEY, tier INTEGER, start_x REAL, start_y REAL, start_z REAL, start_l REAL, start_w REAL, start_h REAL, end_x REAL, end_y REAL, end_z REAL, end_l REAL, end_w REAL, end_h REAL)")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS records (map TEXT, style TEXT, steam_id INTEGER, name TEXT, time REAL, PRIMARY KEY (map, style, steam_id))")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS replays (map TEXT, style TEXT, frame INTEGER, x REAL, y REAL, z REAL, pitch REAL, yaw REAL, PRIMARY KEY (map, style, frame))")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS roles (steam_id INTEGER PRIMARY KEY, role TEXT)")
	sql.QueryTyped("INSERT OR IGNORE INTO roles (steam_id, role) VALUES (?, ?)", OWNER_STEAM_ID_64, ROLE_ADMIN)

	local map = game.GetMap()

	local tempMapCache = sql.QueryTyped("SELECT * FROM maps WHERE map = ?", map) --may return table or false depending on success
	if tempMapCache then
		mapCache = tempMapCache[1] or {}

		startZone:SetPos(Vector(mapCache.start_x, mapCache.start_y, mapCache.start_z))
		endZone:SetPos(Vector(mapCache.end_x, mapCache.end_y, mapCache.end_z))

		startZone.size = Vector(mapCache.start_l, mapCache.start_w, mapCache.start_h)
		endZone.size = Vector(mapCache.end_l, mapCache.end_w, mapCache.end_h)

		startZone:Spawn()
		endZone:Spawn()
	end

	local tempRecordsCache = sql.QueryTyped("SELECT * FROM records WHERE map = ?", map)
	if tempRecordsCache then
		for k, v in pairs(tempRecordsCache) do
			WriteToCache(recordsCache, {name = v.name, time = v.time}, v.style, v.steam_id)
		end
	end

	local tempReplayCache = sql.QueryTyped("SELECT * FROM replays WHERE map = ?", map)
	if tempReplayCache then
		for k, v in pairs(tempReplayCache) do
			WriteToCache(replayCache, {x = v.x, y = v.y, z = v.z, pitch = v.pitch, yaw = v.yaw}, v.style, v.frame)
		end
	end

	local tempRoleCache = sql.QueryTyped("SELECT * FROM roles")
	if tempRoleCache then
		for k, v in pairs(tempRoleCache) do
			roleCache[v.steam_id] = v.role
		end
	end
end

function WriteToCache(cache, value, ...) -- ... represents an infinite number of nested indices, you can index the cache for as many nested indices as the cache table has
	local indices = {...}

    for i = 1, #indices - 1 do
        local key = indices[i]

        if not cache[key] then
            cache[key] = {}
        end

        cache = cache[key]
    end

    cache[indices[#indices]] = value
end

function UpdateTempCache(ply)
	local ply = ply or nil

	net.Start("tempCacheUpdate")
	net.WriteTable(tempCache)

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

function UpdateRecordsCache(ply)
	local ply = ply or nil

	net.Start("recordsCacheUpdate")
	net.WriteTable(recordsCache)

	if ply == nil then
		net.Broadcast()
	else
		net.Send(ply)
	end
end