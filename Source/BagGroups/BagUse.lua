AuctionatorBagUseMixin = {}
function AuctionatorBagUseMixin:OnLoad()
  self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")

  Auctionator.EventBus:RegisterSource(self, "AuctionatorBagUseMixin")

  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemRequest,
    Auctionator.Selling.Events.BagItemClicked,
  })
  self.View.rowWidth = math.ceil(5 * 42 / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
end

function AuctionatorBagUseMixin:OnShow()
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagItemClicked", self.BagItemClicked, self)
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOn")
  self.View:Update(AuctionatorBagCacheFrame)
end

function AuctionatorBagUseMixin:OnHide()
  Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagItemClicked", self)
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOff")
end

function AuctionatorBagUseMixin:ReceiveEvent(eventName, info, ...)
  if eventName == Auctionator.Selling.Events.BagItemRequest then
    local button = (self.View.itemMap[info.name] and self.View.itemMap[info.name][info.sortKey])
    if not button then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ClearBagItem)
    else
      button:Click()
    end
  elseif eventName == Auctionator.Selling.Events.BagItemClicked then
    self.View:SetSelected(info.key)
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
