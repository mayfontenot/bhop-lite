function GM:KeyPress(ply, key)									--spectator target switch
	if ply:Team() == TEAM_SPECTATOR then
		if key == IN_ATTACK or key == IN_ATTACK2 then
			local players = team.GetPlayers(TEAM_PLAYER)
			local target = ply:GetObserverTarget()
			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey + (key == IN_ATTACK and -1 or key == IN_ATTACK2 and 1)

			if targetKey > #players then
				targetKey = 1
			elseif targetKey < 1 then
				targetKey = #players
			end

			target = players[targetKey]

			if IsValid(target) then
				ply:SpectateEntity(target)
			end
		end
	end
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)		--ssj counter
	ply.jumps = ply:KeyDown(IN_JUMP) and ply.jumps + 1 or 1

	if ply.jumps > 1 and ply.jumps % 6 == 0 then
		local vel = ply:GetVelocity():Length2D()

		ply:ChatPrint("[" .. ALT_NAME .. "] Jump " .. ply.jumps .. ": " .. math.Round(vel) .. " u/s")

		for _, v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
			if v:GetObserverTarget() == ply then
				v:ChatPrint("[" .. ALT_NAME .. "] Jump " .. ply.jumps .. ": " .. math.Round(vel) .. " u/s")
			end
		end
	end
end