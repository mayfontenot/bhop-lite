# bhop-lite
A lightweight Bunny Hop gamemode for Garry's Mod<br/>
Unique features: a database to memory caching system, SQLite, minimal network traffic, and optimized code for maximum performance.<br/>
Additional features: Doors fix, breakables fix, telehop fix, lua_run backdoor fix
Made by Mei and FiBzY<br/>
WORK IN PROGRESS, changelevel and ranks system yet to be implemented<br/>

Directions:
1. Place folders in Garry's Mod/garrysmod/ directory
2. Modify Garry's Mod/garrysmod/gamemodes/bhop/gamemode/shared.lua and change OWNER_STEAM_ID_64 to your SteamID64
3. Start your server with the command-line arguments: -console -game garrysmod -tickrate 100 +gamemode bhop +exec server.cfg
4. /start pos1, /start pos2, /end pos1, /end pos2 to setup zones
5. /map \<map\> to save data and change level, currently no map vote system, will be implemented soon
6. Press F1 to open the BHop Lite menu

command prefix: "!" or "/"<br/>
commands:<br/>
commands or help<br/>
restart or r<br/>
usp<br/>
glock<br/>
remove<br/>
auto or normal or n<br/>
manual or easy or legit<br/>
sideways or sw<br/>
halfsideways or hsw<br/>
wonly or w<br/>
aonly or a<br/>
spectate or spec
