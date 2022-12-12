
local ServerPointsAdminPanel = ISPanel:derive("ServerPointsAdminPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_SCALE = FONT_HGT_SMALL / 14


local function OnServerCommand(module, command, arguments)
  if module == "ServerPoints" and command == "get" then
    ServerPointsAdminPanel.instance.balance = "Balance: " .. tostring(arguments[1])
    Events.OnServerCommand.Remove(OnServerCommand)
  end
end

function ServerPointsAdminPanel:createChildren()
  local btnWid = 125 * FONT_SCALE
  local btnHgt = FONT_HGT_SMALL + 5 * 2 * FONT_SCALE
  local padBottom = 10 * FONT_SCALE

  local x = padBottom + getTextManager():MeasureStringX(UIFont.Medium, "Player:") + padBottom
  self.playerSelect = ISComboBox:new(x, padBottom*2 + FONT_HGT_MEDIUM, self.width - x - padBottom, btnHgt, nil, function(_, combo)
    Events.OnServerCommand.Add(OnServerCommand)
    sendClientCommand("ServerPoints", "get", {combo.options[combo.selected]})
  end)
  self.playerSelect:initialise()
  local players = getOnlinePlayers()
  for i = 0, players:size() - 1 do
    self.playerSelect:addOption(players:get(i):getUsername())
  end
  table.sort(self.playerSelect.options)
  self.playerSelect.selected = 1
  Events.OnServerCommand.Add(OnServerCommand)
  sendClientCommand("ServerPoints", "get", {self.playerSelect.options[self.playerSelect.selected]})
  self:addChild(self.playerSelect)

  local z = self.playerSelect.y + self.playerSelect.height + padBottom + FONT_HGT_MEDIUM + padBottom*2
  self.pointsEntry = ISTextEntryBox:new("0", (self.width - btnWid)/2, z, btnWid, FONT_HGT_SMALL + 4)
  self.pointsEntry:initialise()
  self.pointsEntry:instantiate()
  self.pointsEntry:setMaxTextLength(9)
  self.pointsEntry:setOnlyNumbers(true)
  self:addChild(self.pointsEntry)

  z = self.pointsEntry.y + self.pointsEntry.height + padBottom
  self.addButton = ISButton:new((self.width - btnWid)/2 - 5, z, btnWid/2, btnHgt, "GIVE", self, ServerPointsAdminPanel.onOptionMouseDown)
  self.addButton.internal = "GIVE"
  self.addButton:initialise()
  self.addButton:instantiate()
  self:addChild(self.addButton)

  self.takeButton = ISButton:new(self.width/2 + 5, z, btnWid/2, btnHgt, "TAKE", self, ServerPointsAdminPanel.onOptionMouseDown)
  self.takeButton.internal = "TAKE"
  self.takeButton:initialise()
  self.takeButton:instantiate()
  self:addChild(self.takeButton)

  self.spawnButton = ISButton:new((self.width - btnWid/2)/2, z+btnHgt+padBottom/2, btnWid/2, btnHgt, "SPAWN", self, ServerPointsAdminPanel.onSpawn)
  self.spawnButton:initialise()
  self.spawnButton:instantiate()
  self:addChild(self.spawnButton)

  self.cancelButton = ISButton:new((self.width - btnWid)/2, self.height - padBottom - btnHgt, btnWid, btnHgt, getText("UI_btn_close"), self, ServerPointsAdminPanel.close)
  self.cancelButton:initialise()
  self.cancelButton:instantiate()
  self:addChild(self.cancelButton)

  self.reloadButton = ISButton:new(self.cancelButton.x, self.cancelButton.y - padBottom - btnHgt, btnWid, btnHgt, "RELOAD CONFIG", nil, ServerPointsAdminPanel.onReload)
  self.reloadButton:initialise()
  self.reloadButton:instantiate()
  self:addChild(self.reloadButton)
end

function ServerPointsAdminPanel:render()
  self:drawTextCentre("Server Points Panel", self.width / 2, 10 * FONT_SCALE, 1,1,1,1, UIFont.Medium)
  self:drawText("Player:", 10 * FONT_SCALE, self.playerSelect.y + (self.playerSelect.height - FONT_HGT_MEDIUM)/2, 1, 1, 1, 1, UIFont.Medium)
  self:drawText(self.balance, 10 * FONT_SCALE, self.playerSelect.y + self.playerSelect.height + 10 * FONT_SCALE, 1, 1, 1, 1, UIFont.Medium)
end

function ServerPointsAdminPanel:onOptionMouseDown(button)
  if button.internal == "GIVE" then
    sendClientCommand("ServerPoints", "add", {self.playerSelect:getSelectedText(), tonumber(self.pointsEntry:getText())})
  elseif button.internal == "TAKE" then
    sendClientCommand("ServerPoints", "add", {self.playerSelect:getSelectedText(), -tonumber(self.pointsEntry:getText())})
  end
  Events.OnServerCommand.Add(OnServerCommand)
  sendClientCommand("ServerPoints", "get", {self.playerSelect.options[self.playerSelect.selected]})
end

function ServerPointsAdminPanel:onSpawn()
  local item = getPlayer():getInventory():AddItem("Base.ServerPoints")
  local points = tonumber(self.pointsEntry:getText())
  item:getModData().serverPoints = points
  item:setName(points .. " " .. SandboxVars.ServerPoints.PointsName)
end

function ServerPointsAdminPanel.onReload()
  sendClientCommand("ServerPoints", "reload", nil)
end

function ServerPointsAdminPanel:close()
  self:setVisible(false)
  self:removeFromUIManager()
  ServerPointsAdminPanel.instance = nil
end

function ServerPointsAdminPanel:new(x, y, width, height)
  local o = ISPanel:new(x, y, width, height)
  setmetatable(o, self)
  self.__index = self
  o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
  o.backgroundColor = {r=0, g=0, b=0, a=0.8}
  o.moveWithMouse = true
  o.balance = "Balance: 0"
  ServerPointsAdminPanel.instance = o
  return o
end

local function openUI(button)
  if ServerPointsAdminPanel.instance then
      ServerPointsAdminPanel.instance:close()
  end
  local core = getCore()
  local width = 250 * FONT_SCALE
  local height = 270 * FONT_SCALE
  local ui = ServerPointsAdminPanel:new((core:getScreenWidth() - width)/2, (core:getScreenHeight() - height)/2, width, height)
  ui:initialise()
  ui:addToUIManager()
end

local oldISAdminPanelUI_create = ISAdminPanelUI.create
function ISAdminPanelUI:create()
  oldISAdminPanelUI_create(self)

  if getAccessLevel() == "admin" then
    self.serverPointsBtn = ISButton:new(self.sandboxOptionsBtn.x, self.sandboxOptionsBtn.y + 15 + self.sandboxOptionsBtn.height*3, self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "Server Points Options", nil, openUI)
    self.serverPointsBtn.internal = "SERVERPOINTS"
    self.serverPointsBtn:initialise()
    self.serverPointsBtn:instantiate()
    self.serverPointsBtn.borderColor = self.buttonBorderColor
    self:addChild(self.serverPointsBtn)
  end
end
