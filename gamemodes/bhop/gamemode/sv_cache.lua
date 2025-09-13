util.AddNetworkString("playerCacheMessage")
util.AddNetworkString("recordsCacheMessage")

function WriteCacheToDB()
	local map = game.GetMap()
	local startPos, startSize = startZone:GetPos(), startZone.size
	local endPos, endSize = endZone:GetPos(), endZone.size

	sql.QueryTyped("INSERT OR REPLACE INTO maps (map, start_x, start_y, start_z, start_l, start_w, start_h, end_x, end_y, end_z, end_l, end_w, end_h) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", map, startPos.x, startPos.y, startPos.z, startSize.x, startSize.y, startSize.z, endPos.x, endPos.y, endPos.z, endSize.x, endSize.y, endSize.z)

	for style, record in pairs(recordsCache) do
		for steam_id, v in pairs(record) do
			sql.QueryTyped("INSERT OR REPLACE INTO records (map, style, steam_id, name, time) VALUES (?, ?, ?, ?, ?)", map, style, steam_id, v.name, v.time)
		end
	end

	for style, frames in pairs(replayCache) do
		sql.QueryTyped("DELETE FROM replays WHERE map = ? AND style = ?", map, style)

		for frame, v in pairs(frames) do
			sql.QueryTyped("INSERT OR REPLACE INTO replays (map, style, frame, x, y, z, pitch, yaw) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", map, style, frame, v.x, v.y, v.z, v.pitch, v.yaw)
		end
	end

	for steam_id, v in pairs(roleCache) do
		sql.QueryTyped("INSERT OR REPLACE INTO roles (steam_id, role) VALUES (?, ?)", steam_id, v)
	end
end

function ReadCacheFromDB()
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS maps (map TEXT PRIMARY KEY, start_x REAL, start_y REAL, start_z REAL, start_l REAL, start_w REAL, start_h REAL, end_x REAL, end_y REAL, end_z REAL, end_l REAL, end_w REAL, end_h REAL)")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS records (map TEXT, style TEXT, steam_id INTEGER, name TEXT, time REAL, PRIMARY KEY (map, style, steam_id))")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS replays (map TEXT, style TEXT, frame INTEGER, x REAL, y REAL, z REAL, pitch REAL, yaw REAL, PRIMARY KEY (map, style, frame))")
	sql.QueryTyped("CREATE TABLE IF NOT EXISTS roles (steam_id INTEGER PRIMARY KEY, role TEXT)")
	sql.QueryTyped("INSERT OR IGNORE INTO roles (steam_id, role) VALUES (?, ?)", OWNER_STEAM_ID_64, ROLE_ADMIN)

	local map = game.GetMap()

	local tempMapCache = sql.QueryTyped("SELECT * FROM maps WHERE map = ?", map) --may return table or false depending on success
	if tempMapCache then
		tempMapCache = tempMapCache[1]

		startZone:SetPos(Vector(tempMapCache.start_x, tempMapCache.start_y, tempMapCache.start_z))
		endZone:SetPos(Vector(tempMapCache.end_x, tempMapCache.end_y, tempMapCache.end_z))

		startZone.size = Vector(tempMapCache.start_l, tempMapCache.start_w, tempMapCache.start_h)
		endZone.size = Vector(tempMapCache.end_l, tempMapCache.end_w, tempMapCache.end_h)

		startZone:Spawn()
		endZone:Spawn()
	end

	local tempRecordsCache = sql.QueryTyped("SELECT * FROM records WHERE map = ?", map)
	if tempRecordsCache then
		for _, v in pairs(tempRecordsCache) do
			WriteToCache(recordsCache, {name = v.name, time = v.time}, v.style, v.steam_id)
		end
	end

	local tempReplayCache = sql.QueryTyped("SELECT * FROM replays WHERE map = ?", map)
	if tempReplayCache then
		for _, v in pairs(tempReplayCache) do
			WriteToCache(replayCache, {x = v.x, y = v.y, z = v.z, pitch = v.pitch, yaw = v.yaw}, v.style, v.frame)
		end
	end

	local tempRoleCache = sql.QueryTyped("SELECT * FROM roles")
	if tempRoleCache then
		for _, v in pairs(tempRoleCache) do
			roleCache[v.steam_id] = v.role
		end
	end
end

function WriteToCache(cache, value, ...) -- ... represents an infinite number of nested keys, you can index the table for as many nested keys as the table has
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

function NetworkPlayerCache(ply)
	local ply = ply or nil

	net.Start("playerCacheMessage")
	net.WriteTable(playerCache)

	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function NetworkRecordsCache(ply)
	local ply = ply or nil

	net.Start("recordsCacheMessage")
	net.WriteTable(recordsCache)

	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end