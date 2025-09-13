function GM:KeyPress(ply, key)												--spectator target switch
	if ply:Team() == TEAM_SPECTATOR then
		if key == IN_ATTACK or key == IN_ATTACK2 then
			local players = team.GetPlayers(TEAM_PLAYER)
			local target = ply:GetObserverTarget()
			local dir = 0

			if key == IN_ATTACK then
				dir = dir - 1
			elseif key == IN_ATTACK2 then
				dir = dir + 1
			end

			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey + dir

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

		ply:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Jump ' .. ply.jumps .. ': " .. math.Round(' .. vel .. ') .. " u/s")')

		for _, v in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
			if v:GetObserverTarget() == ply then
				v:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Jump ' .. ply.jumps .. ': " .. math.Round(' .. vel .. ') .. " u/s")')
			end
		end
	end
end