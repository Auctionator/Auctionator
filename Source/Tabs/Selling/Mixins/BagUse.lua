AuctionatorBagUseMixin = {}
function AuctionatorBagUseMixin:OnLoad()
  self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")

  Auctionator.EventBus:RegisterSource(self, "AuctionatorBagUseMixin")
  self.View.rowWidth = math.ceil(5 * 42 / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  self.awaitingCompletion = true

  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemRequest,
    Auctionator.Selling.Events.BagItemClicked,
  })
end

function AuctionatorBagUseMixin:OnShow()
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagUse.BagItemClicked", self.BagItemClicked, self)
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagUse.AddToDefaultGroup", self.AddToDefaultGroup, self)

  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagViewComplete", function(_, listsCached)
    self.awaitingCompletion = false
    if self.pendingKey then
      self:ReturnItem(self.pendingKey)
      self.pendingKey = nil
    end
  end, self)

  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOn")
end

function AuctionatorBagUseMixin:OnHide()
  self.awaitingCompletion = true
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagUse.BagItemClicked", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagUse.AddToDefaultGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagUse.RemoveFromDefaultGroup", self)
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagViewComplete", self)
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOff")
end

function AuctionatorBagUseMixin:ReturnItem(info)
  local button = (self.View.itemMap[info.name] and self.View.itemMap[info.name][info.sortKey])
  if not button then
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ClearBagItem)
  else
    button:Click()
  end
end

function AuctionatorBagUseMixin:ReceiveEvent(eventName, info, ...)
  if eventName == Auctionator.Selling.Events.BagItemRequest then
    if self.awaitingCompletion then
      self.pendingKey = info
    else
      self:ReturnItem(info)
    end
  elseif eventName == Auctionator.Selling.Events.BagItemClicked then
    self.View:SetSelected(info.key)
    self.View:ScrollToSelected()
  elseif eventName == Auctionator.Selling.Events.BagItemClear then
    self.View:SetSelected(nil)
  end
end

function AuctionatorBagUseMixin:BagItemClicked(button, mouseButton)
  if mouseButton == "LeftButton" then
    if IsModifiedClick("CHATLINK") then
      ChatEdit_InsertLink(button.itemInfo.itemLink)
    else
      local postingInfo = Auctionator.BagGroups.Utilities.ToPostingItem(button.itemInfo)
      postingInfo.nextItem = button.nextItem
      postingInfo.prevItem = button.prevItem
      postingInfo.key = button.key
      postingInfo.groupName = button.itemInfo.group
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, postingInfo)
    end
  elseif mouseButton == "RightButton" then
    local defaultName = Auctionator.BagGroups.GetGroupNameByIndex(1)
    local isInDefaultGroup = self.View.itemMap[defaultName][button.itemInfo.sortKey] ~= nil
    local options = {}
    local defaultPrintName = _G["AUCTIONATOR_L_" .. defaultName] or defaultName
    if isInDefaultGroup then
      table.insert(options, { label = AUCTIONATOR_L_REMOVE_FROM_X:format(defaultPrintName), callback = function() self:RemoveFromDefaultGroup(button) end})
    else
      table.insert(options, { label = AUCTIONATOR_L_ADD_TO_X:format(defaultPrintName), callback = function() self:AddToDefaultGroup(button) end})
    end
    Auctionator.Selling.ShowPopup(options)
  end
end

function AuctionatorBagUseMixin:AddToDefaultGroup(button)
  local defaultName = Auctionator.BagGroups.GetGroupNameByIndex(1)
  local defaultList = Auctionator.BagGroups.GetGroupList(defaultName)
  if self.View.itemMap[defaultName][button.itemInfo.sortKey] == nil then
    table.insert(defaultList, button.itemInfo.itemLink)
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
  end
end

function AuctionatorBagUseMixin:RemoveFromDefaultGroup(button)
  local defaultName = Auctionator.BagGroups.GetGroupNameByIndex(1)
  local defaultList = Auctionator.BagGroups.GetGroupList(defaultName)
  local info = self.View.itemMap[defaultName][button.itemInfo.sortKey].itemInfo
  for index, itemLink in ipairs(defaultList) do
    local sortKey = AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, info.auctionable).sortKey
    if sortKey == info.sortKey then
      table.remove(defaultList, index)
      Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCustomise.EditMade")
      break
    end
  end
end

function AuctionatorBagUseMixin:ToggleCustomiseMode()
  Auctionator.BagGroups.OpenCustomiseView()
end
