function GM:OnPlayerChat(ply, text, teamChat, isDead)
	if text[1] ~= "!" and text[1] ~= "/" then return end

	if ply == LocalPlayer() then
		text = string.sub(string.lower(text), 2)

		if text == "commands" or text == "help" then
			chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Press F1 for a list of commands.")
		elseif text == "show" then
			RunConsoleCommand("bhoplite_draw_players", 1)
		elseif text == "hide" then
			RunConsoleCommand("bhoplite_draw_players", 0)
		elseif text == "restart" or text == "reset" or text == "r" then
			net.Start("restartMessage")
			net.SendToServer()
		elseif text == "usp" then
			net.Start("weaponMessage")
				net.WriteUInt(0, 2)
			net.SendToServer()
		elseif text == "glock" then
			net.Start("weaponMessage")
				net.WriteUInt(1, 2)
			net.SendToServer()
		elseif text == "knife" then
			net.Start("weaponMessage")
				net.WriteUInt(2, 2)
			net.SendToServer()
		elseif text == "remove" then
			net.Start("weaponMessage")
				net.WriteUInt(3, 2)
			net.SendToServer()
		elseif text == "auto" or text == "normal" or text == "n" then
			net.Start("styleMessage")
				net.WriteString(STYLE_AUTO)
			net.SendToServer()
		elseif text == "manual" or text == "easy" or text == "legit" then
			net.Start("styleMessage")
				net.WriteString(STYLE_MANUAL)
			net.SendToServer()
		elseif text == "sideways" or text == "sw" then
			net.Start("styleMessage")
				net.WriteString(STYLE_SIDEWAYS)
			net.SendToServer()
		elseif text == "halfsideways" or text == "hsw" then
			net.Start("styleMessage")
				net.WriteString(STYLE_HALF_SIDEWAYS)
			net.SendToServer()
		elseif text == "wonly" or text == "w" then
			net.Start("styleMessage")
				net.WriteString(STYLE_W_ONLY)
			net.SendToServer()
		elseif text == "aonly" or text == "a" then
			net.Start("styleMessage")
				net.WriteString(STYLE_A_ONLY)
			net.SendToServer()
		elseif text == "spectate" or text == "spec" then
			net.Start("spectateMessage")
			net.SendToServer()
		elseif string.StartsWith(text, "map ") then
			net.Start("adminMapMessage")
				net.WriteString(string.sub(text, 5))
			net.SendToServer()
		elseif text == "start pos1" then
			net.Start("adminZoneMessage")
				net.WriteBit(0)
				net.WriteBit(0)
			net.SendToServer()
		elseif text == "end pos1" then
			net.Start("adminZoneMessage")
				net.WriteBit(1)
				net.WriteBit(0)
			net.SendToServer()
		elseif text == "start pos2" then
			net.Start("adminZoneMessage")
				net.WriteBit(0)
				net.WriteBit(1)
			net.SendToServer()
		elseif text == "end pos2" then
			net.Start("adminZoneMessage")
				net.WriteBit(1)
				net.WriteBit(1)
			net.SendToServer()
		else
			chat.AddText(Color(151, 211, 255), "[" .. ALT_NAME .. "] Unknown command. Press F1 for a list of commands.")
		end
	end

	return true
end