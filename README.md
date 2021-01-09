# CE-voteTools

### A CobaltEssentials extension to provide vote-based tools on BeamMP Servers

## Installation:

#### 1. Place voteTools.lua in
`.../Resources/Server/CobaltEssentials/extensions/`

#### 2. Add an entry to turn it on in:
`.../Resources/Server/CobaltEssentials/LoadExtensions.cfg`

```cfg
# Add your new extensions here as a key/value pair
# The first one is the name in the lua enviroment
# The second value is the file path to the main lua from CobaltEssentials/extensions

exampleExtension = "exampleExtension"
voteTools = "voteTools"
```
---
## Configuration:
At the top of voteTools.lua you will see some configurables:

```lua
--config these to your preference
local voteKickTimeout = 60 --how long in seconds a voteKick is open
local immuneLevel = 2 --this CE player permission level and above cannot be voted for
local voteKickRatio = 0.3 --what percent of connected players must vote for a candidate for them to be kicked

local voteMapTimeout = 60 --how long in seconds a voteMap is open
local voteMapRatio = 0.5 --what percent of connected players must vote for a map for the map to change
```
---
## Usage:
By default, Everyone can initiate voteKick and voteMap. I made this decision because the point of voting is that players on a server should be able to use these without the need for mods or admins to be present. voteKick uses IDs instead of names, because some names can be difficult to type. voteMap uses shortNames for ease of use.

This extension's commands and aliases are:

`/votekick` or `/vk`

`/vote` or `/v`

`/votecancel` or `/vc`

`/votemap` pr `/vm`

`/changemap` or `/cm`

`/maps` or `/map` or `/maplist` or `/ml`

* To start a voteKick, any player may use `/votekick` or `/vk`. This will print the list of players currently on the server, and give usage instructions for `/vote`.

* When a voteKick is active, players may use `/vote <playerID>` to vote for a player.

* To start a voteMap, any player may use `/voteMap` or `/vm`. This will print the list of maps, and give usage instructions for `/vote`.

* When a voteMap is active, players may use `/vote <shortName>` to vote for a map.

* After a configurable length of time (60 seconds by default), the vote will reset, or server mod/admin/owner can use `/votecancel` at any time.
