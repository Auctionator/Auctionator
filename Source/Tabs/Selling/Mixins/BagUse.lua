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
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagItemClicked", self.BagItemClicked, self)

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
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagItemClicked", self)
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

function AuctionatorBagUseMixin:BagItemClicked(button)
  Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, {
    itemLink = button.itemInfo.itemLink,
    itemID = button.itemInfo.itemID,
    itemName = button.itemInfo.itemName,
    itemLevel = button.itemInfo.itemLevel,
    iconTexture = button.itemInfo.iconTexture,
    quality = button.itemInfo.quality,
    count = button.itemInfo.itemCount,
    location = button.itemInfo.locations[1],
    classId = button.itemInfo.classID,
    auctionable = true,
    bagListing = true,
    nextItem = button.nextItem,
    prevItem = button.prevItem,
    key = button.key,
  })
end

function AuctionatorBagUseMixin:ToggleCustomiseMode()
  Auctionator.BagGroups.OpenCustomiseView()
end
