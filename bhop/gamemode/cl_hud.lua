local hide = {
	["CHudDamageIndicator"] = true, 
	["CHudGeiger"] = true, 
	["CHudHealth"] = true, 
	["CHudBattery"] = true, 
	["CHudSecondaryAmmo"] = true, 
	["CHudSuitPower"] = true
}
local SCR_W, SCR_H = ScrW(), ScrH()
local hudWidth, hudHeight, HUD_TEXT_NUM = 0, 0, 5

local function AddHudRow(text, rowNum)
	local textWidth, textHeight = surface.GetTextSize(text)

	surface.SetTextPos(SCR_W / 2 - textWidth / 2, SCR_H - textHeight - hudHeight + textHeight * rowNum)
	surface.DrawText(text)
end

function GM:HUDPaint()
	surface.SetFont("HudDefault")

	local ply = LocalPlayer()
	local observerTarget = ply:GetObserverTarget()
	ply = IsValid(observerTarget) and observerTarget or ply

	local steamID = ply:SteamID()
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
	local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
	local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
	local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
	local time = timerStart > 0 and (FormatTime(CurTime() - timerStart) .. " s") or "Stopped"

	if ply:IsBot() then
		personalRecord = worldRecord
	end

	worldRecord = worldRecord > 0 and ("WR: " .. FormatRecord(worldRecord) .. " s (" .. ReadFromCache(worldRecordsCache, "N/A", style, "name") .. ")") or "WR: None"
	personalRecord = personalRecord > 0 and ("PR: " .. FormatRecord(personalRecord) .. " s") or "PR: None"

	local textWidth, textHeight = surface.GetTextSize(worldRecord)

	hudWidth = textWidth + textHeight * 2
	hudHeight = textHeight * (HUD_TEXT_NUM + 2)

	draw.RoundedBox(16, SCR_W / 2 - hudWidth / 2, SCR_H - textHeight - hudHeight, hudWidth, hudHeight, Color(0, 0, 0, 100))

	surface.SetTextColor(255, 255, 255)

	if IsValid(observerTarget) then
		AddHudRow(observerTarget:Name(), 0)
	end

	AddHudRow(style, 1)
	AddHudRow(time, 2)
	AddHudRow(math.Round(ply:GetVelocity():Length2D()) .. " u/s", 3)
	AddHudRow(personalRecord, 4)
	AddHudRow(worldRecord, 5)
end

local SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT = SCR_W / 2, SCR_H / 1.75

local function AddScoreboardRow(rowNum, numColumns, ...)
	local elements = {...}

	local textHeight = select(2, surface.GetTextSize(elements[1]))
	textHeight = textHeight * 1.5

	for k, v in ipairs(elements) do
		surface.SetTextPos(SCR_W / 2 - SCOREBOARD_WIDTH / 2 + textHeight + (SCOREBOARD_WIDTH / numColumns * (k - 1)), SCR_H / 2 - SCOREBOARD_HEIGHT / 2 + textHeight * rowNum)
		surface.DrawText(v)
	end
end

local drawScoreboard = false

function GM:HUDDrawScoreBoard()
	if not drawScoreboard then return end

	draw.RoundedBox(16, SCR_W / 2 - SCOREBOARD_WIDTH / 2, SCR_H / 2 - SCOREBOARD_HEIGHT / 2, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, Color(0, 0, 0, 100))

	surface.SetFont("HudDefault")
	surface.SetTextColor(255, 255, 255)

	AddScoreboardRow(1, 1, GetHostName())
	AddScoreboardRow(2, 1, "Tier " .. ReadFromCache(mapCache, 1, "tier") .. " " .. game.GetMap())
	AddScoreboardRow(3, 5, "Name", "Style", "Timer", "Personal Record", "Ping")

	for k, v in ipairs(player.GetAll()) do
		local teamColor = v:Team() == TEAM_SPECTATOR and team.GetColor(v:Team()) or Color(255, 255, 255)
		local steamID = v:SteamID()
		local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
		local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")

		local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
		personalRecord = personalRecord > 0 and (FormatRecord(personalRecord) .. " s") or "None"

		if v:IsBot() then
			local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
			worldRecord = worldRecord > 0 and (FormatRecord(worldRecord) .. " s") or "None"
			personalRecord = worldRecord
		end

		local time = timerStart > 0 and (FormatTime(CurTime() - timerStart)  .. " s") or "Stopped"

		AddScoreboardRow(3 + k, 5, v:Name(), style, time, personalRecord, v:Ping())
	end
end

function GM:ScoreboardShow()
	drawScoreboard = true
end

function GM:ScoreboardHide()
	drawScoreboard = false
end

function GM:HUDShouldDraw(name)
	return not hide[name]
end

function GM:HUDItemPickedUp(itemName)
end