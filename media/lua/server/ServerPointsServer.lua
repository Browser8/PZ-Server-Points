
function Recipe.OnCreate.RedeemPoints(items, result, player)
	local points = items:get(0):getModData().serverPoints or 0
	sendClientCommand("ServerPoints", "add", {player:getUsername(), points})
	player:Say("Redeemed " .. points.. " " .. SandboxVars.ServerPoints.PointsName)
end

if not isServer() then return end

local serverPointsData
local listings

local function PointsTick()
	local players = getOnlinePlayers()
  for i = 0, players:size() - 1 do
    local username = players:get(i):getUsername()
    if not serverPointsData[username] then serverPointsData[username] = 0 end
    serverPointsData[username] = serverPointsData[username] + SandboxVars.ServerPoints.PointsPerTick
  end
end

local function LoadListings()
	local fileReader = getFileReader("ServerPointsListings.ini", true)
	local lines = {}
	local line = fileReader:readLine()
	while line do
		table.insert(lines, line)
		line = fileReader:readLine()
	end
  fileReader:close()
	listings = loadstring(table.concat(lines))() or {["Missing Configuration"] = {}}
end

Events.OnInitGlobalModData.Add(function(isNewGame)
	serverPointsData = ModData.getOrCreate("serverPointsData")

	LoadListings()

	if SandboxVars.ServerPoints.PointsFrequency == 2 then
	  Events.EveryTenMinutes.Add(PointsTick)
	elseif SandboxVars.ServerPoints.PointsFrequency == 3 then
	  Events.EveryHours.Add(PointsTick)
	elseif SandboxVars.ServerPoints.PointsFrequency == 4 then
	  Events.EveryDays.Add(PointsTick)
	end
end)

local ServerPointsCommands = {}

function ServerPointsCommands.get(module, command, player, args)
	sendServerCommand(player, module, command, {serverPointsData[args and args[1] or player:getUsername()] or 0})
end

function ServerPointsCommands.buy(module, command, player, args)
	print(string.format("[SERVER POINTS] %s bought %s for %d points", player:getUsername(), args[2], args[1]))
	if not serverPointsData[player:getUsername()] then serverPointsData[player:getUsername()] = 0 end
	serverPointsData[player:getUsername()] = serverPointsData[player:getUsername()] - math.abs(args[1])
end

function ServerPointsCommands.vehicle(module, command, player, args)
	local vehicle = addVehicleDebug(args[1], IsoDirections.S, nil, player:getSquare())
	for i = 0, vehicle:getPartCount() - 1 do
		local container = vehicle:getPartByIndex(i):getItemContainer()
		if container then
			container:removeAllItems()
		end
	end
	vehicle:repair()
	player:sendObjectChange("addItem", {item = vehicle:createVehicleKey()})
end

function ServerPointsCommands.add(module, command, player, args)
	print(string.format("[SERVER POINTS] %s gave %s %d points", player:getUsername(), args[1], args[2]))
	if not serverPointsData[args[1]] then serverPointsData[args[1]] = 0 end
	serverPointsData[args[1]] = serverPointsData[args[1]] + args[2]
end

function ServerPointsCommands.load(module, command, player, args)
	sendServerCommand(player, module, command, listings)
end

function ServerPointsCommands.reload(module, command, player, args)
	LoadListings()
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if module == "ServerPoints" and ServerPointsCommands[command] then
		ServerPointsCommands[command](module, command, player, args)
	end
end)

return ServerPointsCommands
