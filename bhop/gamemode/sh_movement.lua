function GM:SetupMove(ply, mv, cmd)
	local steamID = ply:SteamID64()

	if SERVER then
		if not ply:IsBot() then			--record replays
			if ReadFromCache(tempCache, 0, steamID, "timer_start") > 0 then
				ply.replayMV = ply.replayMV and ply.replayMV + 1 or 1

				local pos, ang = mv:GetOrigin(), ply:EyeAngles()

				if not ply.replayCache then
					ply.replayCache = {}
				end

				ply.replayCache[ply.replayMV] = {x = pos.x, y = pos.y, z = pos.z, pitch = ang.p, yaw = ang.y}
			else
				ply.replayCache = {}
				ply.replayMV = 0
			end
		elseif ply:IsBot() then						--play replay
			if not ply.replayMV then
				ply:SetMoveType(MOVETYPE_NONE)
				ply:SetRenderMode(RENDERMODE_NONE)
				ply:SetFOV(100)

				ply.replayMV = 1
			end

			local mvTable = ReadFromCache(replayCache, nil, ReadFromCache(tempCache, STYLE_AUTO, steamID, "style"))

			if mvTable then
				local spectators = GetSpectators(ply)

				if #spectators > 0 and ply.replayMV == 1 then
					WriteToCache(tempCache, CurTime(), steamID, "timer_start")
					UpdateTempCache()
				end

				mv:SetOrigin(Vector(mvTable[ply.replayMV].x, mvTable[ply.replayMV].y, mvTable[ply.replayMV].z))
				ply:SetEyeAngles(Angle(mvTable[ply.replayMV].pitch, mvTable[ply.replayMV].yaw, 0))

				if #spectators > 0 then
					ply.replayMV = ply.replayMV + 1
				end

				if ply.replayMV > #mvTable or #spectators == 0 then
					WriteToCache(tempCache, 0, steamID, "timer_start")
					UpdateTempCache()

					ply.replayMV = 1
				end
			end
		end
	end

	if ply:GetMoveType() ~= MOVETYPE_WALK then return end

	local onGround = ply:OnGround()
	local style = ReadFromCache(tempCache, STYLE_AUTO, steamID, "style")

	--autohop by FiBzY to be crouch boost fix compatible
	if style ~= STYLE_MANUAL and cmd:KeyDown(IN_JUMP) and onGround and ply:WaterLevel() < 2 then
		mv:SetOldButtons(mv:GetButtons() - IN_JUMP)
	end

	if cmd:KeyDown(IN_JUMP) and onGround and ply:Crouching() then	--FiBzY's crouch boost fix
		ply:SetDuckSpeed(0)
		ply:SetUnDuckSpeed(0)
	else
		ply:SetDuckSpeed(0.4)
		ply:SetUnDuckSpeed(0.2)
	end

	if onGround then return end

	if style == STYLE_SIDEWAYS or style == STYLE_W_ONLY then			--movement restrictions
		mv:SetSideSpeed(0)

		if style == STYLE_W_ONLY and mv:GetForwardSpeed() < 0 then
			mv:SetForwardSpeed(0)
		end
	elseif style == STYLE_A_ONLY then
		mv:SetForwardSpeed(0)

		if mv:GetSideSpeed() > 0 then
			mv:SetSideSpeed(0)
		end
	elseif style == STYLE_HALF_SIDEWAYS and (mv:GetForwardSpeed() == 0 or mv:GetSideSpeed() == 0) then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
	end
end

local AIR_ACCEL = 500

function GM:Move(ply, mv)
	if ply:OnGround() or ply:Team() == TEAM_SPECTATOR then return end

	local style = ReadFromCache(tempCache, STYLE_AUTO, ply:SteamID64(), "style")
	local vel, ang = mv:GetVelocity(), mv:GetMoveAngles()
	local forward, right = ang:Forward(), ang:Right()
	local fSpeed, sSpeed = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local maxSpeed = mv:GetMaxSpeed()

	if style == STYLE_AUTO then
		if mv:KeyDown(IN_MOVELEFT) then
			sSpeed = sSpeed - AIR_ACCEL
		elseif mv:KeyDown(IN_MOVERIGHT) then
			sSpeed = sSpeed + AIR_ACCEL
		end
	elseif style == STYLE_SIDE_WAYS then
		if mv:KeyDown(IN_FORWARD) then
			fSpeed = fSpeed + AIR_ACCEL
		elseif mv:KeyDown(IN_BACK) then
			fSpeed = fSpeed - AIR_ACCEL
		end
	end

	forward.z, right.z = 0, 0

	forward:Normalize()
	right:Normalize()

	local wishVel = forward * fSpeed + right * sSpeed
	wishVel.z = 0

	local wishSpeed = wishVel:Length()

	if wishSpeed > maxSpeed then
		wishVel = wishVel * (maxSpeed / wishSpeed)
		wishSpeed = maxSpeed
	end

	local wishSpeedDir = wishSpeed
	wishSpeedDir = math.Clamp(wishSpeedDir, 0, 32.8)

	local wishDir = wishVel:GetNormal()
	local currentDir = mv:GetVelocity():Dot(wishDir)
	local addSpeed = wishSpeedDir - currentDir

	if addSpeed <= 0 then return end

	local accelSpeed = AIR_ACCEL * FrameTime() * wishSpeed

	if accelSpeed > addSpeed then
		accelSpeed = addSpeed
	end

	vel = vel + wishDir * accelSpeed

	mv:SetVelocity(vel)

	return false
end