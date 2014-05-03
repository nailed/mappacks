local points = scoreboard.getObjective("points")
local timeout = scoreboard.getObjective("timeout")
local allPlayers = map.getPlayers()
local players = map.getPlayers()
local pkp
local pd

points.setDisplayName("Points")
scoreboard.setDisplay(points, "sidebar")

local function shutdown()
  if pkp ~= nil then
    eventbus.removeListener(pkp)
  end
  if pd ~= nil then
    eventbus.removeListener(pd)
  end
  map.stopGame()
end

if #allPlayers < 2 then
  printError("You don't have enough players to play this game. You need at least 2 players")
  shutdown()
end

local function giveItems(p)
  p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Giving Items ...","color":"dark_gray"}]}]])
  p.clearInventory()
  p.giveItem("minecraft:stone_sword",1)
  p.giveItem("minecraft:bow",1)
  p.giveItem("minecraft:arrow",10)
  p.giveItem("minecraft:leather_helmet",1)
  p.giveItem("minecraft:leather_chestplate",1)
  p.giveItem("minecraft:leather_leggings",1)
  p.giveItem("minecraft:leather_boots",1)
end

function endGame()
  --sleep(1)
  for i = 1, #allPlayers do
    p = allPlayers[i]
    p.clearInventory()
    p.setGamemode(gamemodes.survival)
    --p.setHealth(20)
    p.setFood(20)
    p.setExperience(0)
    p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Player ","color":"dark_green","bold":"true"},{"text":"]] .. winner.getUsername() .. [[","color":"green","bold":"true"},{"text":" has won!","color":"dark_green","bold":"true"}]}]])
    p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Game Ended","color":"dark_green","bold":"true"}]}]])
  end
  shutdown()
end

local function onPlayerDeath(player)
  for i = #players, 1, -1 do
    if players[i].getUsername() == player.getUsername() then
      table.remove(players, i)
    end
  end
  if #players == 1 then
    print("Final kill made")
    winner = players[1]
    map.setWinner(winner)
    winner.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Bonus ] ","color":"white"},{"text":"You Won!","color":"dark_green","bold":"true"}]}]])
    points.addScore(winner.getUsername(),25)
    endGame()
  end
end

--Event handlers
pd = eventbus.addListener("player_die", onPlayerDeath)
pkp = eventbus.addListener("player_kill_player", function(source , victim, ds)
  if os.getTicks() - timeout.getScore(source.getUsername()) < 20 then
    source.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"schow_text","value":"[ Together We Cry ]","color":"red"}},{"text":" [ Bonus ] ","color":"white"},{"text":"Double Kill!","color":"dark_red","bold":"true"}]}]])
    timeout.setScore(source.getUsername(),os.getTicks())
    points.addScore(source.getUsername(),20)
  else
    points.addScore(source.getUsername(),5)
    timeout.setScore(source.getUsername(),os.getTicks())
  end
  onPlayerDeath(victim)
end)

--Start gamescript
for p = 1, #players do
  pl = players[p]
  print(pl)
  pl.freeze(true)
  pl.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Game Starting","color":"dark_green","bold":"true"}]}]])
  pl.setGamemode(gamemodes.survival)
  pl.setFood(20)
  pl.setHealth(20)
  print(pl.getUsername())
  points.setScore(pl.getUsername(), points.getScore(pl.getUsername()))
  timeout.setScore(pl.getUsername(), os.getTicks() - 21)
  giveItems(pl)
end

map.spreadPlayers()
map.forEachPlayer(function(p)
  p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Spreading Players","color":"dark_gray"}]}]])
end)

map.countdown(5, "Game Starting in %s")
map.sendTimeUpdate("Game Started")

for p = 1, #players do
  players[p].freeze(false)
  players[p].setHealth(20)
end

while true do
  sleep(1)
end
