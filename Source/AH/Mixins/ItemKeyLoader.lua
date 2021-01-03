AuctionatorAHItemKeyLoaderFrameMixin = {}

local ITEM_KEY_INFO_EVENTS = {
  "ITEM_KEY_ITEM_INFO_RECEIVED"
}

function AuctionatorAHItemKeyLoaderFrameMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorItemKeyLoadingMixin")
  self.waiting = {}
  self.cache = {}
  self.waitingCount = 0
  self.registered = false
end

function AuctionatorAHItemKeyLoaderFrameMixin:Get(itemKey)
  local itemKeyString = Auctionator.Utilities.ItemKeyString(itemKey)
  local info = self.cache[itemKeyString]
  if info then
    Auctionator.EventBus:Fire(
      self,
      Auctionator.AH.Events.ItemKeyInfo,
      itemKey,
      info,
      true
    )
    return
  end

  info = C_AuctionHouse.GetItemKeyInfo(itemKey)
  if info then
    self.cache[itemKeyString] = info
    Auctionator.EventBus:Fire(
      self,
      Auctionator.AH.Events.ItemKeyInfo,
      itemKey,
      info,
      false
    )
  else
    if self.waiting[itemKey.itemID] == nil then
      self.waiting[itemKey.itemID] = {}

      self.waitingCount = self.waitingCount + 1
    end

    if not self.registered then
      self.registered = true
      FrameUtil.RegisterFrameForEvents(self, ITEM_KEY_INFO_EVENTS)

      Auctionator.Debug.Message("AuctionatorAHItemKeyLoaderFrameMixin", self.registered)
    end

    self:MergeRequests(itemKey)
  end
end

function AuctionatorAHItemKeyLoaderFrameMixin:MergeRequests(itemKey)
  local keyString = Auctionator.Utilities.ItemKeyString(itemKey)
  for _, key in ipairs(self.waiting[itemKey.itemID]) do
    if keyString == Auctionator.Utilities.ItemKeyString(key) then
      return
    end
  end

  table.insert(self.waiting[itemKey.itemID], itemKey)
end

function AuctionatorAHItemKeyLoaderFrameMixin:OnEvent(event, itemID)
  if (
    event == "ITEM_KEY_ITEM_INFO_RECEIVED" and
    self.waiting[itemID] ~= nil
  ) then

    local itemKeys = self.waiting[itemID]

    self.waitingCount = self.waitingCount -1
    self.waiting[itemID] = nil

    for _, key in ipairs(itemKeys) do
      self:Get(key)
    end
  end

  if self.waitingCount == 0 and self.registered then
    self.registered = false
    FrameUtil.UnregisterFrameForEvents(self, ITEM_KEY_INFO_EVENTS)

    Auctionator.Debug.Message("AuctionatorAHItemKeyLoaderFrameMixin", self.registered)
  end
end
