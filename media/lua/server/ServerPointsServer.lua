
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

local function OnInitGlobalModData(isNewGame)
	serverPointsData = ModData.getOrCreate("serverPointsData")

	LoadListings()

	if SandboxVars.ServerPoints.PointsFrequency == 2 then
	  Events.EveryTenMinutes.Add(PointsTick)
	elseif SandboxVars.ServerPoints.PointsFrequency == 3 then
	  Events.EveryHours.Add(PointsTick)
	elseif SandboxVars.ServerPoints.PointsFrequency == 4 then
	  Events.EveryDays.Add(PointsTick)
	end
end

local function OnClientCommand(module, command, player, args)
	if module == "ServerPoints" then
		if command == "get" then
	    sendServerCommand(player, module, command, {serverPointsData[player:getUsername()] or 0})
		elseif command == "buy" then
			print(string.format("[SERVER POINTS] %s bought %s for %d points", player:getUsername(), args[2], args[1]))
			if not serverPointsData[player:getUsername()] then serverPointsData[player:getUsername()] = 0 end
			serverPointsData[player:getUsername()] = serverPointsData[player:getUsername()] - math.abs(args[1])
		elseif command == "vehicle" then
			local vehicle = addVehicleDebug(args[1], IsoDirections.S, nil, player:getSquare())
      vehicle:repair()
			player:sendObjectChange("addItem", {item = vehicle:createVehicleKey()})
		elseif command == "add" and player:getAccessLevel() == "Admin" then
			print(string.format("[SERVER POINTS] %s gave %s %d points", player:getUsername(), args[1], args[2]))
			if not serverPointsData[args[1]] then serverPointsData[args[1]] = 0 end
			serverPointsData[args[1]] = serverPointsData[args[1]] + args[2]
		elseif command == "load" then
			sendServerCommand(player, module, command, listings)
		elseif command == "reload" then
			LoadListings()
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
