SB2BagUseMixin = {}
function SB2BagUseMixin:OnLoad()
  self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")

  Auctionator.EventBus:RegisterSource(self, "SB2BagUseMixin")

  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemRequest,
    Auctionator.Selling.Events.BagItemClicked,
  })
  self.View.rowWidth = math.ceil(5 * 42 / Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  print(self.View.rowWidth)
end

function SB2BagUseMixin:OnShow()
  print("show")
  SB2.CallbackRegistry:RegisterCallback("BagItemClicked", self.BagItemClicked, self)
  SB2.CallbackRegistry:TriggerEvent("BagCacheOn")
  self.View:Update(SB2BagCacheFrame)
end

function SB2BagUseMixin:OnHide()
  SB2.CallbackRegistry:UnregisterCallback("BagItemClicked", self)
  SB2.CallbackRegistry:TriggerEvent("BagCacheOff")
end

function SB2BagUseMixin:ReceiveEvent(eventName, info, ...)
  if eventName == Auctionator.Selling.Events.BagItemRequest then
    local button = (self.View.itemMap[info.name] and self.View.itemMap[info.name][info.sortKey])
    if not button then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ClearBagItem)
    else
      button:Click()
    end
  elseif eventName == Auctionator.Selling.Events.BagItemClicked then
    print(info.key)
    self.View:SetSelected(info.key)
  elseif eventName == Auctionator.Selling.Events.BagItemClear then
    print("clear")
    self.View:SetSelected(nil)
  end
end

function SB2BagUseMixin:BagItemClicked(button)
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

function SB2BagUseMixin:ToggleCustomiseMode()
  SB2BagCustomiseFrame:Show()
end
