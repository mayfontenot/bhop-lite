function GM:SetupMove(ply, mv, cmd)
	local onGround = ply:OnGround()

	if ply:GetMoveType() ~= MOVETYPE_WALK then return end

	if ReadFromCache(tempPlayerCache, STYLE_AUTO, ply:SteamID(), "style") ~= STYLE_MANUAL and onGround and cmd:KeyDown(IN_JUMP) and ply:WaterLevel() < 2 then	--autohop
		mv:SetOldButtons(mv:GetButtons() - IN_JUMP)
	end

	if onGround and ply:Crouching() and cmd:KeyDown(IN_JUMP) then	--crouch boost fix
        ply:SetDuckSpeed(0)
        ply:SetUnDuckSpeed(0)
    else
        ply:SetDuckSpeed(0.4)
        ply:SetUnDuckSpeed(0.2)
    end

	if onGround then return end

	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, ply:SteamID(), "style")

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

	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, ply:SteamID(), "style")
	local vel, ang = mv:GetVelocity(), mv:GetMoveAngles()
	local forward, right = ang:Forward(), ang:Right()
	local fSpeed, sSpeed = mv:GetForwardSpeed(), mv:GetSideSpeed()
	local maxSpeed = mv:GetMaxSpeed()

	if style == STYLE_NORMAL then
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