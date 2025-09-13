--cache commonly used methods and constants, these are not precached by the lua engine
surface = surface
surface.GetTextSize = surface.GetTextSize
surface.SetTextPos = surface.SetTextPos
surface.DrawText = surface.DrawText
surface.SetTextColor = surface.SetTextColor
surface.SetFont = surface.SetFont
surface.SetDrawColor = surface.SetDrawColor
surface.DrawRect = surface.DrawRect

net.Receive("playerCacheMessage", function(len, ply)
	playerCache = net.ReadTable()
end)

net.Receive("recordsCacheMessage", function(len, ply)
	recordsCache = net.ReadTable()
end)