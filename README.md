# CE-voteKick

### A CobaltEssentials extension to allow simple votekick-ing on BeamMP Servers

## Installation:

#### 1. Place voteKick.lua in .../Resources/Server/CobaltEssentials/extensions/

The next few steps are required to support and use this extension:

#### 2. ADD THE FOLLOWING TO .../Resources/Server/CobaltEssentials/lua/CobaltCommands.lua, NOTE THE SECTIONS THESE BELONG IN:

```lua
---------------------------------------------FUNCTIONS---------------------------------------------

local function votekick(player, ... )
	extensions.triggerEvent("onVoteStart", player.playerID)
end

local function vote(player, voteID, ... )
	extensions.triggerEvent("onVote", player.playerID, tonumber(voteID))
end

local function votecancel(player, ... )
	extensions.triggerEvent("onVoteReset", player.playerID)
end

---------------------------------------------PUBLICINTERFACE---------------------------------------------

----COMMANDS----

M.votekick = votekick
M.vote = vote
M.votecancel = votecancel
```

#### 3. ADD THE FOLLOWING TO .../Resources/Server/CobaltEssentials/CobaltDB/commands.json, MIND YOUR SYNTAX:

```json
"votekick":{	
	"description":"Prints the playerList and starts a voteKick",
	"level":0,
	"arguments":0,
	"sourceLimited":0,
	"orginModule":"extensions"
},
"vote":{	
	"description":"Vote for a player to be kicked, \/vote <ID>",
	"level":0,
	"arguments":1,
	"sourceLimited":0,
	"orginModule":"extensions"
},
"votecancel":{	
	"description":"Cancel a voteKick",
	"level":9,
	"arguments":0,
	"sourceLimited":0,
	"orginModule":"extensions"
},
```

#### 4. ADD THE FOLLOWING TO .../Resources/Server/CobaltEssentials/LoadExtensions.cfg, REPLACING OR PLACED UNDER THE EXAMPLE

```cfg
# Add your new extensions here as a key/value pair
# The first one is the name in the lua enviroment
# The second value is the file path to the main lua from CobaltEssentials/extensions

exampleExtension = "exampleExtension"
voteKick = "voteKick"
```

## Configuration:
At the top of voteKick.lua you will see three configurables:

```lua
--config these to your preference
local voteTimeout = 60 --how long a voteKick is open
local immuneLevel = 2 --this CE player permission level and above cannot be voted for
local voteRatio = 0.3 --what percent of connected players must vote for a candidate for them to be kicked
```

## Usage:

By default, Everyone can initiate voteKicks. I made this decision because the point of a votekick is that players on a server should be able to use this method to remove troublesome players without the need for mods or admins to be present. This votekick uses IDs instead of names, because some names can be difficult to type.

This extension's commands are:
```
/votekick
/vote
/votecancel
```

* To start a voteKick, any player may use '/votekick'. This will print the list of players currently on the server, and give usage instructions for '/vote'.

* When a voteKick is active, players may use '/vote <playerID>' to vote for a player.

* After a configurable length of time (60 seconds by default), the vote will reset, or server mod/admin/owner can use /votecancel at any time.
