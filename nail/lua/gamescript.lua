local teamred = map.getTeam("teamred")
local teamblue = map.getTeam("teamblue")
local kills = scoreboard.getObjective("kills")

kills.setDisplayName("Player Kills")

teamblue.forEachPlayer(function(p)
	kills.setScore(p.getUsername(), 0)
end)
teamred.forEachPlayer(function(p)
	kills.setScore(p.getUsername(), 0)
end)

local listener = eventbus.addListener("player_kill_player", function(src, dest, source)
	kills.addScore(src.getUsername(), 1)
end)

print("Starting initial countdown")
map.watchUnready(true)
map.countdown(10, "The game will start in %s")
map.watchUnready(false)
map.winnerInterrupt(true)

scoreboard.setDisplay(kills, "sidebar")

print("Starting team blue")
teamblue.setSpawn(903,86,1192)
teamblue.forEachPlayer(function(p)
	p.clearInventory()
	p.setGamemode(gamemodes.survival)
	p.setHealth(20)
	p.setFood(20)
	p.setExperience(0)
end)
map.enableStat("startblue")

print("Setting the time and difficulty")
map.setTime(12500)
map.setDifficulty(difficulty.normal)

print("60 seconds countdown")
map.countdown(60, "%s left until the invaders will be released")

print("Starting team red")
teamred.setSpawn(922,84,787)
teamred.forEachPlayer(function(p)
	p.clearInventory()
	p.setGamemode(gamemodes.survival)
	p.setHealth(20)
	p.setFood(20)
	p.setExperience(0)
end)
map.enableStat("startred")

print("Waiting for the game to finish")
map.countdown(20 * 60, "%s left")
print("No winner after 20 minutes. Setting winner to team blue")
map.setWinner(teamblue)
map.setDifficulty(difficulty.peaceful)

eventbus.removeListener(listener)
