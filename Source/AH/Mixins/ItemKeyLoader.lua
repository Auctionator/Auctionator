AuctionatorAHItemKeyLoaderFrameMixin = {}

local ITEM_KEY_INFO_EVENTS = {
  "ITEM_KEY_ITEM_INFO_RECEIVED"
}

function AuctionatorAHItemKeyLoaderFrameMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorItemKeyLoadingMixin")
  FrameUtil.RegisterFrameForEvents(self, ITEM_KEY_INFO_EVENTS)
  self.waiting = {}
end

function AuctionatorAHItemKeyLoaderFrameMixin:Get(itemKey)
  if self.waiting[itemKey.itemID] == nil then
    self.waiting[itemKey.itemID] = {}
  end

  local info = C_AuctionHouse.GetItemKeyInfo(itemKey)
  if info then
    Auctionator.EventBus:Fire(
      self,
      Auctionator.AH.Events.ItemKeyInfo,
      itemKey,
      info
    )
  else
    table.insert(self.waiting[itemKey.itemID], itemKey)
  end
end

function AuctionatorAHItemKeyLoaderFrameMixin:OnEvent(event, itemID)
  if (
    event == "ITEM_KEY_ITEM_INFO_RECEIVED" and
    self.waiting[itemID] ~= nil
  ) then

    local itemKeys = self.waiting[itemID]
    self.waiting[itemID] = {}

    for index, key in ipairs(itemKeys) do
      self:Get(key)
    end
  end
end
