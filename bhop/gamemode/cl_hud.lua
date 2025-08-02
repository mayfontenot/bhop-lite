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
	local time = timerStart > 0 and (FormatTime(CurTime() - timerStart) .. " s") or "In Zone"

	worldRecord = worldRecord > 0 and ("WR: " .. FormatRecord(worldRecord) .. " s (" .. ReadFromCache(worldRecordsCache, "N/A", style, "name") .. ")") or "WR: None"
	personalRecord = personalRecord > 0 and ("PR: " .. FormatRecord(personalRecord) .. " s") or "PR: None"

	local textWidth, textHeight = surface.GetTextSize(worldRecord)

	hudWidth = textWidth + textHeight * 2
	hudHeight = textHeight * (HUD_TEXT_NUM + 2)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(SCR_W / 2 - hudWidth / 2, SCR_H - textHeight - hudHeight, hudWidth, hudHeight)
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

local SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, SCOREBOARD_COLUMN_NUM = SCR_W / 2, SCR_H / 2, 5

local function AddScoreboardRow(rowNum, ...)
	local elements = {...}

	local textHeight = select(2, surface.GetTextSize(elements[1]))
	textHeight = textHeight * 1.5

	for k, v in ipairs(elements) do
		surface.SetTextPos(SCR_W / 2 - SCOREBOARD_WIDTH / 2 + textHeight + (SCOREBOARD_WIDTH / SCOREBOARD_COLUMN_NUM * (k - 1)), SCR_H / 2 - SCOREBOARD_HEIGHT / 2 + textHeight * rowNum)
		surface.DrawText(v)
	end
end

local drawScoreboard = false

function GM:HUDDrawScoreBoard()
	if not drawScoreboard then return end

	surface.SetFont("HudDefault")
	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(SCR_W / 2 - SCOREBOARD_WIDTH / 2, SCR_H / 2 - SCOREBOARD_HEIGHT / 2, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT)

	local title = GetHostName() .. " on Tier " .. ReadFromCache(mapCache, 1, "tier") .. " " .. game.GetMap()
	local textWidth, textHeight = surface.GetTextSize(title)
	textHeight = textHeight * 1.5

	surface.SetTextColor(255, 255, 255)
	surface.SetTextPos(SCR_W / 2 - textWidth / 2, SCR_H / 2 - SCOREBOARD_HEIGHT / 2 + textHeight)
	surface.DrawText(title)

	AddScoreboardRow(2, "Name", "Style", "Time", "Personal Record", "Ping")

	for k, v in ipairs(player.GetAll()) do
		local teamColor = v:Team() == TEAM_SPECTATOR and team.GetColor(v:Team()) or Color(255, 255, 255)
		local steamID = v:SteamID()
		local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
		local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
		local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
		local time = timerStart > 0 and (FormatTime(CurTime() - timerStart)  .. " s") or "In Zone"

		personalRecord = personalRecord > 0 and (FormatRecord(personalRecord) .. " s") or "None"

		AddScoreboardRow(2 + k, v:Name(), style, time, personalRecord, v:Ping())
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