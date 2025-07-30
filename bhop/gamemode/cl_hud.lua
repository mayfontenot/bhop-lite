local hide = {
	["CHudDamageIndicator"] = true, 
	["CHudGeiger"] = true, 
	["CHudHealth"] = true, 
	["CHudBattery"] = true, 
	["CHudSecondaryAmmo"] = true, 
	["CHudSuitPower"] = true
}
local scrW, scrH = ScrW(), ScrH()
local hudWidth, hudHeight, hudTextNum = 0, 0, 5

local function AddHudRow(text, rowNum)
	local textWidth, textHeight = surface.GetTextSize(text)

	surface.SetTextPos(scrW / 2 - textWidth / 2, scrH - textHeight - hudHeight + textHeight * rowNum)
	surface.DrawText(text)
end

function GM:HUDPaint()
	surface.SetFont("HudDefault")

	local ply = LocalPlayer()
	local observerTarget = ply:GetObserverTarget()
	ply = IsValid(observerTarget) and observerTarget or ply
	local velocity = math.Round(ply:GetVelocity():Length2D())
	local steamID = ply:SteamID()
	local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
	local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
	local worldRecord = ReadFromCache(worldRecordsCache, 0, style, "time")
	local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
	local timeElapsed = timerStart > 0 and CurTime() - timerStart or 0
	local longestString = "PR " .. ConvertTime(personalRecord) .. " (+" .. ConvertTime(personalRecord - worldRecord) .. ")"
	local textWidth, textHeight = surface.GetTextSize(longestString)
	hudWidth = textWidth + textHeight * 2
	hudHeight = textHeight * (hudTextNum + 2)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(scrW / 2 - hudWidth / 2, scrH - textHeight - hudHeight, hudWidth, hudHeight)
	surface.SetTextColor(255, 255, 255)

	if IsValid(observerTarget) then
		AddHudRow(observerTarget:Name(), 0)
	end

	AddHudRow(style, 1)
	AddHudRow(ConvertTime(timeElapsed), 2)
	AddHudRow(velocity .. " u/s", 3)
	AddHudRow(longestString, 4)
	AddHudRow("WR " .. ConvertTime(worldRecord) .. "", 5)
end

local scoreboardWidth, scoreboardHeight = scrW / 2, scrH / 2
local drawScoreboard = false

function GM:HUDDrawScoreBoard()
	if not drawScoreboard then return end

	surface.SetFont("HudDefault")
	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(scrW / 2 - scoreboardWidth / 2, scrH / 2 - scoreboardHeight / 2, scoreboardWidth, scoreboardHeight)

	local title = GetHostName() .. " on Tier " .. ReadFromCache(mapCache, 1, "tier") .. " " .. game.GetMap()
	local textWidth, textHeight = surface.GetTextSize(title)
	textHeight = textHeight * 1.5

	surface.SetTextColor(255, 255, 255)
	surface.SetTextPos(scrW / 2 - textWidth / 2, scrH / 2 - scoreboardHeight / 2 + textHeight)
	surface.DrawText(title)

	surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 0), scrH / 2 - scoreboardHeight / 2 + textHeight * 2)
	surface.DrawText("Name")

	surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 1), scrH / 2 - scoreboardHeight / 2 + textHeight * 2)
	surface.DrawText("Style")

	surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 2), scrH / 2 - scoreboardHeight / 2 + textHeight * 2)
	surface.DrawText("Time")

	surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 3), scrH / 2 - scoreboardHeight / 2 + textHeight * 2)
	surface.DrawText("Personal Record")

	for k, v in ipairs(player.GetAll()) do
		local steamID = v:SteamID()
		local style = ReadFromCache(tempPlayerCache, STYLE_AUTO, steamID, "style")
		local timerStart = ReadFromCache(tempPlayerCache, 0, steamID, "timerStart")
		local personalRecord = ReadFromCache(personalRecordsCache, 0, steamID, style)
		local timeElapsed = timerStart > 0 and CurTime() - timerStart or 0

		surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 0), scrH / 2 - scoreboardHeight / 2 + textHeight * (k + 2))
		surface.DrawText(v:Name())
		surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 1), scrH / 2 - scoreboardHeight / 2 + textHeight * (k + 2))
		surface.DrawText(style)
		surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 2), scrH / 2 - scoreboardHeight / 2 + textHeight * (k + 2))
		surface.DrawText(ConvertTime(timeElapsed))
		surface.SetTextPos(scrW / 2 - scoreboardWidth / 2 + textHeight + (scoreboardWidth / 4 * 3), scrH / 2 - scoreboardHeight / 2 + textHeight * (k + 2))
		surface.DrawText(ConvertTime(personalRecord))
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