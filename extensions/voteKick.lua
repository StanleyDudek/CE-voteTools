local M = {}

--config these to your preference
local voteTimeout = 60 --how long in ms a voteKick is open
local immuneLevel = 2 --this CE player permission level and above cannot be voted for
local voteRatio = 0.3 --what percent of connected players must vote for a candidate for them to be kicked

--ignore these
local playerCount = 0
local voteLast = 0
local voteActive = false
local voteCount = {}
local voteFor = {}

--called whenever the extension is loaded
local function onInit()
	RegisterEvent("onVoteStart","onVoteStart")
	RegisterEvent("onVote","onVote")
	RegisterEvent("onVoteReset","onVoteReset")
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
local voteKickCommands = 
{
	--orginModule[commandName] is where the command is executed from
	-- Source-Limit-Map [0:no limit | 1:Chat Only | 2:RCON Only]
	votekick =			{orginModule = "voteKick",	level = 0,	arguments = 0,	sourceLimited = 0,	description = "Prints usage info and starts a voteKick"},
	vote =				{orginModule = "voteKick",	level = 0,	arguments = 1,	sourceLimited = 0,	description = "Votes for the target player by ID, /vote <ID>"},
	votecancel =			{orginModule = "voteKick",	level = 10,	arguments = 0,	sourceLimited = 0,	description = "Stops and resets a voteKick"}

}

--apply them
applyCommands(commands, voteKickCommands)

--called when someone uses /votekick
--print the playerlist and give the players usage info for /vote
local function onVoteStart(sender)
	if voteActive == true then
		SendChatMessage(players[sender].playerID, "The voteKick timeout has not ended. Please wait, or admins use /votecancel")
	else
		voteLast = os.clock()
		voteActive = true
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

--called when someone uses /vote
--if a vote is active, then evaluate the vote's validity and provide context
local function onVote(sender, voteID)
	if voteActive == true then
	
		if players[voteID] ~= nil then
			if players[voteID].permissions.level < immuneLevel then
				local voter = players[sender].playerID
				local candidate = players[voteID].playerID
				if voteFor[voter] ~= nil then
					SendChatMessage(players[sender].playerID, "You cannot vote to kick " .. players[voteID].name .. ", you have already voted to kick " .. players[voteFor[voter]].name)
				else
					if voteCount[candidate] == nil then
						voteCount[candidate] = 1
						voteFor[voter] = candidate
					else
						voteCount[candidate] = voteCount[candidate] + 1
						voteFor[voter] = candidate
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

--called when someone uses /voteCancel or after the vote timeout
--we nil our voteCount and voteFor, set voteActive to false, and inform everyone it has been reset
local function onVoteReset(sender)
	for candidate, votes in pairs(voteCount) do
		voteCount[candidate] = nil
	end
	for voter, vote in pairs(voteFor) do
		voteFor[voter] = nil
	end
	voteActive = false
	SendChatMessage(-1, "voteKick reset!")
	print("voteKick reset by " .. players[sender].name .. "!")
end

--called once every tick
--checks if voteKick is active. If it is, but we've passed the timeout, it resets the voteKick, otherwise
--checks our current playercount and set the threshold of votes based on ratio configured above, then
--checks if the playercount is over three, if it is we will use our ratio to evaluate who to kick, otherwise the threshold is 2 votes, then
--checks for players that have votes over the ratio threshold, and if they are, kicks them immediately,
--they won't be able to rejoin until either the voteKick naturally times out or is manually reset.
local function onTick(age)
	age = age / 1000
	if voteActive == true then
		if age >= voteLast + voteTimeout then
			onVoteReset()
			voteLast = voteLast + voteTimeout
		else
			local votePlayerCount = 0
			for playerID, player in pairs(players) do
				if type(playerID) == "number" then
					votePlayerCount = votePlayerCount + 1
				end
			end
			if votePlayerCount > 3 then
				local voteThresh = votePlayerCount / voteRatio / 10
				for candidate, votes in pairs(voteCount) do
					if votes >= voteThresh then
						DropPlayer(candidate, "You've been voteKicked from the server")
					end
				end
			else
				local voteThresh = 2
				for candidate, votes in pairs(voteCount) do
					if votes >= voteThresh then
						DropPlayer(candidate, "You've been voteKicked from the server")
					end
				end
			end
		end
	end
end

local function votekick(player, ... )
	onVoteStart(player.playerID)
end

local function vote(player, voteID, ... )
	onVote(player.playerID, tonumber(voteID))
end

local function votecancel(player, ... )
	onVoteReset(player.playerID)
end

M.onInit = onInit
M.onTick = onTick

M.onVoteStart = onVoteStart
M.onVote = onVote
M.onVoteReset = onVoteReset

M.votekick = votekick
M.vote = vote
M.votecancel = votecancel

return M
