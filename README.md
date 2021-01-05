# CE-voteKick

### A CobaltEssentials extension to allow simple votekick-ing on BeamMP Servers

## Installation:

#### 1. Place voteKick.lua in
`.../Resources/Server/CobaltEssentials/extensions/`

#### 2. Add an entry to turn it on in:
`.../Resources/Server/CobaltEssentials/LoadExtensions.cfg`

```cfg
# Add your new extensions here as a key/value pair
# The first one is the name in the lua enviroment
# The second value is the file path to the main lua from CobaltEssentials/extensions

exampleExtension = "exampleExtension"
voteKick = "voteKick"
```
---
## Configuration:
At the top of voteKick.lua you will see three configurables:

```lua
--config these to your preference
local voteTimeout = 60 --how long a voteKick is open
local immuneLevel = 2 --this CE player permission level and above cannot be voted for
local voteRatio = 0.3 --what percent of connected players must vote for a candidate for them to be kicked
```
---
## Usage:
By default, Everyone can initiate voteKicks. I made this decision because the point of a votekick is that players on a server should be able to use this method to remove troublesome players without the need for mods or admins to be present. This votekick uses IDs instead of names, because some names can be difficult to type.

This extension's commands are:

`/votekick`
`/vote`
`/votecancel`

* To start a voteKick, any player may use `/votekick`. This will print the list of players currently on the server, and give usage instructions for `/vote`.

* When a voteKick is active, players may use `/vote <playerID>` to vote for a player.

* After a configurable length of time (60 seconds by default), the vote will reset, or server mod/admin/owner can use `/votecancel` at any time.
