
local ServerPointsAdminPanel = ISPanel:derive("ServerPointsAdminPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_SCALE = FONT_HGT_SMALL / 14


function ServerPointsAdminPanel:createChildren()
  local btnWid = 125 * FONT_SCALE
  local btnHgt = FONT_HGT_SMALL + 5 * 2 * FONT_SCALE
  local padBottom = 10 * FONT_SCALE

  self.playerSelect = ISComboBox:new(self.width - padBottom - btnWid, padBottom*2 + FONT_HGT_SMALL, btnWid, btnHgt)
  self.playerSelect:initialise()
  local players = getOnlinePlayers()
  for i = 0, players:size() - 1 do
    self.playerSelect:addOption(players:get(i):getUsername())
  end
  self:addChild(self.playerSelect)

  local z = self.playerSelect.y + padBottom + btnHgt
  self.pointsEntry = ISTextEntryBox:new("0", (self.width - btnWid)/2, z, btnWid, btnHgt)
  self.pointsEntry:initialise()
  self.pointsEntry:instantiate()
  self.pointsEntry:setMaxTextLength(9)
  self.pointsEntry:setOnlyNumbers(true)
  self:addChild(self.pointsEntry)

  z = z + btnHgt + padBottom
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

  self.cancelButton = ISButton:new((self.width - btnWid)/2, self.height - padBottom - btnHgt, btnWid, btnHgt, getText("UI_btn_close"), self, ServerPointsAdminPanel.onOptionMouseDown)
  self.cancelButton.internal = "CANCEL"
  self.cancelButton:initialise()
  self.cancelButton:instantiate()
  self:addChild(self.cancelButton)
end

function ServerPointsAdminPanel:render()
  self:drawText("Server Points Panel", (self.width - getTextManager():MeasureStringX(UIFont.Small, "Server Points Panel")) / 2, 10 * FONT_SCALE, 1,1,1,1, UIFont.Small)
  self:drawText("Player:", 10 * FONT_SCALE, self.playerSelect.y + (self.playerSelect.height - FONT_HGT_SMALL)/2, 1, 1, 1, 1, UIFont.Small)
end

function ServerPointsAdminPanel:onOptionMouseDown(button)
  if button.internal == "GIVE" then
    sendClientCommand("ServerPoints", "add", {self.playerSelect:getSelectedText(), tonumber(self.pointsEntry:getText())})
  elseif button.internal == "TAKE" then
    sendClientCommand("ServerPoints", "add", {self.playerSelect:getSelectedText(), -tonumber(self.pointsEntry:getText())})
  elseif button.internal == "CANCEL" then
    self:close()
  end
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
    o.width = width
    o.height = height
    o.moveWithMouse = true
    ServerPointsAdminPanel.instance = o
    return o
end

local function openUI(self, button)
  if ServerPointsAdminPanel.instance then
      ServerPointsAdminPanel.instance:close()
  end
  local core = getCore()
  local width = 200 * FONT_SCALE
  local height = 175 * FONT_SCALE
  local ui = ServerPointsAdminPanel:new((core:getScreenWidth() - width)/2, (core:getScreenHeight() - height)/2, width, height);
  ui:initialise();
  ui:addToUIManager();
end

local oldISAdminPanelUI_create = ISAdminPanelUI.create
function ISAdminPanelUI:create()
  oldISAdminPanelUI_create(self)

  self.serverPointsBtn = ISButton:new(self.sandboxOptionsBtn.x, self.sandboxOptionsBtn.y + 15 + self.sandboxOptionsBtn.height*3, self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "Server Points Options", self, openUI)
  self.serverPointsBtn.internal = "SERVERPOINTS"
  self.serverPointsBtn:initialise()
  self.serverPointsBtn:instantiate()
  self.serverPointsBtn.borderColor = self.buttonBorderColor
  self:addChild(self.serverPointsBtn)
end
