function GM:KeyPress(ply, key)
	if ply:Team() == TEAM_SPECTATOR then
		if key == IN_ATTACK then
			local players = player.GetAll()
			local target = ply:GetObserverTarget() or players[1]
			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey + 1 > #players and 1 or targetKey + 1
			target = players[targetKey]

			if IsValid(target) and target ~= ply then
				ply:SpectateEntity(target)
			end
		elseif key == IN_ATTACK2 then
			local players = player.GetAll()
			local target = ply:GetObserverTarget() or players[1]
			local targetKey = table.KeyFromValue(players, target)
			targetKey = targetKey - 1 < 1 and #players or targetKey - 1
			target = players[targetKey]

			if IsValid(target) and target ~= ply then
				ply:SpectateEntity(target)
			end
		end
	end
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)
	ply.jumps = ply:KeyDown(IN_JUMP) and ply.jumps + 1 or 0

	if ply.jumps > 0 and ply.jumps % 6 == 0 then
		ply:SendLua('chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Jump ' .. ply.jumps .. ': ' .. math.Round(ply:GetVelocity():Length2D()) .. ' u/s")')
	end
end