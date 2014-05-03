local points = scoreboard.getObjective("Points")
local timeout = scoreboard.getObjective("timeout")
scoreboard.setDisplay(points,"sidebar")
gamedone = false

local function GiveItems(p)
  p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Giving Items ...","color":"dark_gray"}]}]])
  p.clearInventory()
  p.giveItem("minecraft:arrow",10)
  p.giveItem("minecraft:bow",1)
  p.giveItem("minecraft:stone_sword",1)
  p.giveItem("minecraft:leather_helmet",1)
  p.giveItem("minecraft:leather_chestplate",1)
  p.giveItem("minecraft:leather_leggings",1)
  p.giveItem("minecraft:leather_boots",1)
end

print("[ log ] [ TwC ] Adding event hanlers to event bus")

pkp = eventbus.addListener("player_kill_player", function(source , victim, ds)
  print("player kill player")
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

function onPlayerDeath(player)
  print("player death")
  for i = #players, 1, -1 do
    if players[i].getUsername() == player.getUsername() then
      table.remove(players, i)
    end
  end
  print(#players)
  if #players == 1 then
    winner = players[1]
    map.setWinner(winner)
    winner.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Bonus ] ","color":"white"},{"text":"You Won!","color":"dark_green","bold":"true"}]}]])
    points.addScore(winner.getUsername(),25)
    EndGame()
    gamedone = true
  end
end

pd = eventbus.addListener("player_die", onPlayerDeath)

print("[ log ] [ TwC ] Starting game")

players = map.getPlayers()

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
  GiveItems(pl)
end

print("[ log ] [ TwC ] Spreading players")

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

function EndGame()
  local pls = map.getPlayers()
  
  sleep(0.1)
  gamedone = true
  
  for i = 1, #pls do
    p = pls[i]
    p.clearInventory()
    p.setGamemode(gamemodes.survival)
    p.setHealth(20)
    p.setFood(20)
    p.setExperience(0)
    p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Player ","color":"dark_green"},{"text":"]] .. winner.getUsername() .. [[","color":"green","bold":"true"},{"text":" has won!","color":"dark_green","bold":"true"}]}]])
    p.sendChatComponent([[{"text":"","extra":[{"text":"[ TwC ]","color":"red","hoverEvent":{"action":"show_text","value":"[ Together we Cry ]","color":"red"}},{"text":" [ Info ] ","color":"white"},{"text":"Game Ended","color":"dark_green","bold":"true"}]}]])
  end
  
  print("[ log ] [ TwC ] Game done!")
end

if #players == 1 then
  winner = players[1]
  map.setWinner(winner)
  EndGame() 
  gamedone = true
end

while not gamedone do sleep(1) end
eventbus.removeListener(pkp)
eventbus.removeListener(pd)
