local M = {}

--config these to your preference
local voteKickTimeout = 60 --how long in ms a voteKick is open
local immuneLevel = 2 --this CE player permission level and above cannot be voted for
local voteKickRatio = 0.3 --what percent of connected players must vote for a candidate for them to be kicked

local voteMapTimeout = 60 --how long in ms a voteKick is open
local voteMapRatio = 0.5 --what percent of connected players must vote for a candidate for them to be kicked

--ignore these
local playerCount = 0
local voteKickLast = 0
local voteKickActive = false
local voteKickCount = {}
local voteKickFor = {}

local voteMapLast = 0
local voteMapActive = false
local voteMapCount = {}
local voteMapFor = {}

local paths = {
	
	gm = "/levels/gridmap/info.json",
	att = "/levels/automation_test_track/info.json",
	ecu = "/levels/east_coast_usa/info.json",
	hr = "/levels/hirochi_raceway/info.json",
	italy = "/levels/italy/info.json",
	jri = "/levels/jungle_rock_island/info.json",
	si = "/levels/small_island/info.json",
	sg = "/levels/smallgrid/info.json",
	utah = "/levels/utah/info.json",
	wcu = "/levels/west_coast_usa/info.json",
	dt = "/levels/driver_training/info.json",
	derby = "/levels/derby/info.json",
	ind = "/levels/industrial/info.json",
	
	gridmap = "/levels/gridmap/info.json",
	automation = "/levels/automation_test_track/info.json",
	east = "/levels/east_coast_usa/info.json",
	hirochi = "/levels/hirochi_raceway/info.json",
	jungle = "/levels/jungle_rock_island/info.json",
	small = "/levels/small_island/info.json",
	smallgrid = "/levels/smallgrid/info.json",
	utah = "/levels/utah/info.json",
	west = "/levels/west_coast_usa/info.json",
	driver = "/levels/driver_training/info.json",
	industrial = "/levels/industrial/info.json"
	
}

local mapNames = {
	
	gm = "Gridmap",
	att = "Automation Test Track",
	ecu = "East Coast USA",
	hr = "Hirochi Raceway",
	italy = "Italy",
	jri = "Jungle Rock Island",
	si = "Small Island",
	sg = "Smallgrid",
	utah = "Utah",
	wcu = "West Coast USA",
	dt = "Driver Training",
	derby = "Derby",
	ind = "Industrial",
	
	gridmap = "Gridmap",
	automation = "Automation Test Track",
	east = "East Coast USA",
	hirochi = "Hirochi Raceway",
	jungle = "Jungle Rock Island",
	small = "Small Island",
	smallgrid = "Smallgrid",
	utah = "Utah",
	west = "West Coast USA",
	driver = "Driver Training",
	industrial = "Industrial"
	
}

--called whenever the extension is loaded
local function onInit()

end

--function to apply the new commands to the server
local function applyCommands(targetDatabase, tables)
	local appliedTables = {}

	for tableName, table in pairs(tables) do
		--check to see if the database already recognizes this table.
		--if CobaltDB.tableExists(targetDatabase.CobaltDB_databaseName, tableName)  == false then --TODO: update this to an Object-Oriented method.
		if targetDatabase[tableName]:exists() == false then
			--write the key/value table into the database
			for key, value in pairs(table) do
				targetDatabase[tableName][key] = value
			end
			appliedTables[tableName] = tableName
		end
	end
	return appliedTables
end

--info re: new commands for applyCommands to apply
local voteToolsCommands = 
{
	--orginModule[commandName] is where the command is executed from
	-- Source-Limit-Map [0:no limit | 1:Chat Only | 2:RCON Only]
	votekick =			{orginModule = "voteTools",	level = 0,	arguments = 0,	sourceLimited = 0,	description = "Prints usage info and starts a voteKick"},
	vote =				{orginModule = "voteTools",	level = 0,	arguments = 1,	sourceLimited = 0,	description = "Votes for the target player by ID, /vote <ID>"},
	votecancel =		{orginModule = "voteTools",	level = 10,	arguments = 0,	sourceLimited = 0,	description = "Stops and resets a voteKick"},

	votemap =			{orginModule = "voteTools",	level = 0,	arguments = 0,	sourceLimited = 0,	description = "Prints usage info and starts a voteMap"},

	changemap =			{orginModule = "voteTools",	level = 10,	arguments = 1,	sourceLimited = 0,	description = "Changes map and immediately stops server. HIGHLY RECCOMMENDED TO HAVE A RESTART SCRIPT."},
	cm =				{orginModule = "voteTools",	level = 10,	arguments = 1,	sourceLimited = 0,	description = "Changes map and immediately stops server. HIGHLY RECCOMMENDED TO HAVE A RESTART SCRIPT."},

	maps =				{orginModule = "voteTools",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "List the stock maps and their shortnames"},
	map =				{orginModule = "voteTools",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "List the stock maps and their shortnames"},
	maplist =			{orginModule = "voteTools",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "List the stock maps and their shortnames"},
	ml =				{orginModule = "voteTools",	level = 1,	arguments = 0,	sourceLimited = 0,	description = "List the stock maps and their shortnames"},

}

--apply them
applyCommands(commands, voteToolsCommands)

--called when someone uses /votekick or /votemap
--print the playerlist and give the players usage info for /vote
local function onVoteKickStart(sender)
	if voteKickActive == true then
		SendChatMessage(players[sender].playerID, "The voteKick timeout has not ended. Please wait, or admins use /votecancel")
	else
		voteKickLast = os.clock()
		voteKickActive = true
		local playersList = ""
		local playersInQueue = ""
		local specPlayersList = ""
		local currentPlayer
		playerCount = 0
		for playerID, player in pairs(players) do
			if type(playerID) == "number" then
				playerCount = playerCount + 1
				currentPlayer = tostring(playerID) .. ": " .. tostring(player.name) .. "\n"
				if player.gamemode.mode == 0 then 
					playersList = playersList .. "[A] " .. currentPlayer
				elseif player.gamemode.mode == 1 then
					specPlayersList = specPlayersList .. "[Q] " .. currentPlayer
				elseif player.gamemode.mode == 2 then
					specPlayersList = specPlayersList .. "[S] " .. currentPlayer
				end
			end
		end
		playersList = playersList .. specPlayersList
		SendChatMessage(-1, playersList)
		SendChatMessage(-1, "A voteKick has started! Please refer to the player list above and use /vote <ID> to vote to kick that player.")
		print(players[sender].name .. " started a voteKick!")
	end
	
end

local function onVoteMapStart(sender)
	if voteMapActive == true then
		SendChatMessage(players[sender].playerID, "The voteMap timeout has not ended. Please wait, or admins use /votecancel")
	else
		voteMapLast = os.clock()
		voteMapActive = true
	local mapList = ""
	for shortName,fullName in pairs(mapNames) do
		mapList = mapList .. tostring(shortName) .. ": " .. fullName .. "\n"
	end
		SendChatMessage(-1, mapList)
		SendChatMessage(-1, "A voteMap has started! Please refer to the map list above and use /vote <shortName> to vote to change to that map.")
		print(players[sender].name .. " started a voteMap!")
	end
end

--called when someone uses /vote
--if a vote is active, then evaluate the vote's validity and provide context
local function onVoteKick(sender, voteID)
	if voteKickActive == true then
	
		if players[voteID] ~= nil then
			if players[voteID].permissions.level < immuneLevel then
				local voter = players[sender].playerID
				local candidate = players[voteID].playerID
				if voteKickFor[voter] ~= nil then
					SendChatMessage(players[sender].playerID, "You cannot vote to kick " .. players[voteID].name .. ", you have already voted to kick " .. players[voteKickFor[voter]].name)
				else
					if voteKickCount[candidate] == nil then
						voteKickCount[candidate] = 1
						voteKickFor[voter] = candidate
					else
						voteKickCount[candidate] = voteKickCount[candidate] + 1
						voteKickFor[voter] = candidate
					end
					print(players[sender].name .. " voted to kick " .. players[voteID].name)
					SendChatMessage(players[sender].playerID, "You have voted to kick " .. players[voteID].name)
				end
			else
				print(players[sender].name .. " voted to kick " .. players[voteID].name .. ", but they are immune!")
				SendChatMessage(players[sender].playerID, players[voteID].name .. " is immune from voteKick")
			end
		else
			print(players[sender].name .. " voted to kick using an invalid ID")
			SendChatMessage(players[sender].playerID, "That player is not here, vote for someone else!")
		end
	else
		print(players[sender].name .. " tried to vote while voteKick was closed")
		SendChatMessage(players[sender].playerID, "voteKick is not active, start one with /votekick")
	end
	
end

local function onVoteMap(sender, map)
local mapName
	if voteMapActive == true then
		local matchCount = 0
		for shortName,fullName in pairs(mapNames) do
			if tostring(shortName) == map then
				matchCount = matchCount + 1
			end
		end
		if matchCount == 1 then
			for shortName,fullName in pairs(mapNames) do
				if tostring(shortName) == map then
					--if players[voteID].permissions.level < immuneLevel then
						local voter = players[sender].playerID
						mapName = tostring(fullName)
						if voteMapFor[voter] ~= nil then
							SendChatMessage(players[sender].playerID, "You cannot vote for " .. mapName .. ", you have already voted for " .. voteMapFor[voter])
						else
							if voteMapCount[mapName] == nil then
								voteMapCount[mapName] = 1
								voteMapFor[voter] = mapName
							else
								voteMapCount[mapName] = voteMapCount[mapName] + 1
								voteMapFor[voter] = mapName
							end
							print(players[sender].name .. " voted for " .. mapName)
							SendChatMessage(players[sender].playerID, "You have voted for " .. mapName)
						end
					--else
						--print(players[sender].name .. " voted to kick " .. players[voteID].name .. ", but they are immune!")
						--SendChatMessage(players[sender].playerID, players[voteID].name .. " is immune from voteKick")
					--end
				end
			end
		else
			print(players[sender].name .. " voted with an invalid shortName")
			SendChatMessage(players[sender].playerID, "Invalid shortName")
		end
	else
		print(players[sender].name .. " tried to vote while voteMap was closed")
		SendChatMessage(players[sender].playerID, "voteMap is not active, start one with /votemap")
	end
end

--called when someone uses /voteCancel or after the vote timeout
--we nil our voteKickCount and voteKickFor, set voteKickActive to false, and inform everyone it has been reset
local function onVoteReset(sender)
	for candidate, votes in pairs(voteKickCount) do
		voteKickCount[candidate] = nil
	end
	for voter, vote in pairs(voteKickFor) do
		voteKickFor[voter] = nil
	end
	voteKickActive = false
	
	for map, votes in pairs(voteMapCount) do
		voteMapCount[map] = nil
	end
	for voter, vote in pairs(voteMapFor) do
		voteMapFor[voter] = nil
	end
	voteMapActive = false
	
	SendChatMessage(-1, "votes reset!")
	print("votes reset!")
end

--called once every tick
--checks if voteKick is active. If it is, but we've passed the timeout, it resets the voteKick, otherwise
--checks our current playercount and set the threshold of votes based on ratio configured above, then
--checks if the playercount is over three, if it is we will use our ratio to evaluate who to kick, otherwise the threshold is 2 votes, then
--checks for players that have votes over the ratio threshold, and if they are, kicks them immediately,
--they won't be able to rejoin until either the voteKick naturally times out or is manually reset.
local function onTick(age)
	--age = age / 1000 --if you use default CE age calcs, uncomment this
	if voteKickActive == true then
		if age >= voteKickLast + voteKickTimeout then
			onVoteReset()
			voteKickLast = voteKickLast + voteKickTimeout
		else
			local votePlayerCount = 0
			for playerID, player in pairs(players) do
				if type(playerID) == "number" then
					votePlayerCount = votePlayerCount + 1
				end
			end
			if votePlayerCount > 3 then
				local voteThresh = votePlayerCount / voteKickRatio / 10
				for candidate, votes in pairs(voteKickCount) do
					if votes >= voteThresh then
						DropPlayer(candidate, "You've been voteKicked from the server")
					end
				end
			else
				local voteThresh = 2
				for candidate, votes in pairs(voteKickCount) do
					if votes >= voteThresh then
						DropPlayer(candidate, "You've been voteKicked from the server")
					end
				end
			end
		end
	end
	
	if voteMapActive == true then
		if age >= voteMapLast + voteMapTimeout then
			onVoteReset()
			voteMapLast = voteMapLast + voteMapTimeout
		else
			local votePlayerCount = 0
			for playerID, player in pairs(players) do
				if type(playerID) == "number" then
					votePlayerCount = votePlayerCount + 1
				end
			end
			if votePlayerCount > 3 then
				local voteThresh = votePlayerCount / voteMapRatio / 10
				for map, votes in pairs(voteMapCount) do
					if votes >= voteThresh then
						M.changemap(-1, map)
					end
				end
			else
				local voteThresh = 2
				for map, votes in pairs(voteMapCount) do
					if votes >= voteThresh then
						M.changemap(-1, map)
					end
				end
			end
		end
	end
	
end

--function to kick everyone
function dropAll()
	for playerID, player in ipairs(players), players, -1 do
		DropPlayerV(playerID, "Map changed!")
	end
end

--prints the map list and their short names
local function maps(sender, ...)
	local mapList = ""
	for shortName,fullName in pairs(mapNames) do
		mapList = mapList .. tostring(shortName) .. ": " .. fullName .. "\n"
	end
	return mapList
end

--changes the map and kicks everyone after 10 seconds
local function changemap(sender, map, ...)
	local matchCount = 0
	for shortName,fullName in pairs(mapNames) do
		if tostring(shortName) == map then
			matchCount = matchCount + 1
		end
	end
	if matchCount == 1 then
		for shortName,mapPath in pairs(paths) do
			if map == shortName then
				map = mapPath
			else
			end
		end
		local curMap
		if beamMPconfig["Map"] then
			curMap = beamMPconfig["Map"]
			for shortName,mapPath in pairs(paths) do
				if curMap == mapPath then
					curMap = shortName
					for shortName,fullName in pairs(mapNames) do
						if curMap == shortName then
						curMap = fullName
						end
					end
				end
			end
			beamMPconfig["Map"] = map
			for shortName,mapPath in pairs(paths) do
				if map == mapPath then
					map = shortName
					for shortName,fullName in pairs(mapNames) do
						if map  == shortName then
							map = fullName
						end
					end
				end
			end
			SendChatMessage(-1, "Map changed from " .. curMap .. " to " .. map)
			SendChatMessage(-1, "Everyone will be kicked in 10 seconds, please rejoin!")
		end
		CE.delayExec( 10 , dropAll , {} )
	else
		return "Invalid shortName"
	end
end

local function votekick(player, ... )
	onVoteKickStart(player.playerID)
end

local function vote(player, voteID, ... )
	if type(tonumber(voteID)) == "number" then
		onVoteKick(player.playerID, tonumber(voteID))
	else
		onVoteMap(player.playerID, voteID)
	end
end

local function votecancel(player, ... )
	onVoteReset(player.playerID)
end

local function votemap(player, ... )
	onVoteMapStart(player.playerID)
end

M.onInit = onInit
M.onTick = onTick

M.votekick = votekick
M.votemap = votemap
M.vote = vote
M.votecancel = votecancel

M.changemap = changemap
M.cm = changemap
M.maps = maps
M.map = maps
M.maplist = maps
M.ml = maps

return M
