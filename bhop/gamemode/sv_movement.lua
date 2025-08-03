function GM:KeyPress(ply, key)
	if ply:Team() == TEAM_SPECTATOR then
		if key == IN_ATTACK then
			local players = team.GetPlayers(TEAM_PLAYER)
			local target = ply:GetObserverTarget()

			if not target or target:Team() == TEAM_SPECTATOR then
				target = players[1]
			end

			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey + 1 > #players and 1 or targetKey + 1

			target = players[targetKey]

			if IsValid(target) and target ~= ply then
				ply:SpectateEntity(target)
			end
		elseif key == IN_ATTACK2 then
			local players = team.GetPlayers(TEAM_PLAYER)
			local target = ply:GetObserverTarget()

			if not target or target:Team() == TEAM_SPECTATOR then
				target = players[1]
			end

			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey - 1 < 1 and #players or targetKey - 1

			target = players[targetKey]

			if IsValid(target) and target ~= ply and target:Team() ~= TEAM_SPECTATOR then
				ply:SpectateEntity(target)
			end
		end
	end
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)		--ssj counter
	ply.jumps = ply:KeyDown(IN_JUMP) and ply.jumps + 1 or 1

	if ply.jumps > 1 and ply.jumps % 6 == 0 then
		ply:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Jump ' .. ply.jumps .. ': " .. math.Round(' .. ply:GetVelocity():Length2D() .. ') .. " u/s")')

		for _, v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
			if v:GetObserverTarget() == ply then
				v:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Jump ' .. ply.jumps .. ': " .. math.Round(' .. ply:GetVelocity():Length2D() .. ') .. " u/s")')
			end
		end
	end
end

function GM:FinishMove(ply, mv)				--save movedata for replay
	if not ply:IsBot() then
		local steamID = ply:SteamID()

		if ReadFromCache(tempPlayerCache, 0, steamID, "timerStart") > 0 then
			ply.replayMV = ply.replayMV and ply.replayMV + 1 or 1

			local pos, ang = mv:GetOrigin(), ply:EyeAngles()

			WriteToCache(replayCache, {["posX"] = pos.x, ["posY"] = pos.y, ["posZ"] = pos.z, ["angP"] = ang.p, ["angY"] = ang.y}, steamID, ply.replayMV)
		else
			WriteToCache(replayCache, {}, steamID)
			ply.replayMV = 0
		end
	end
end