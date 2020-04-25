-- Exact search terms
Auctionator.Search.Filters.ExactMixin = {}

local EXACT_EVENTS = {
  Auctionator.Search.Events.BlizzardInfo
}

function Auctionator.Search.Filters.ExactMixin:Init(browseResult, match)
  Auctionator.EventBus:Register(self, EXACT_EVENTS)

  self.browseResult = browseResult
  self.match = match
  
  self:TryComplete()
end

function Auctionator.Search.Filters.ExactMixin:TryComplete()
  if self.match ~= nil then
    local itemKey = self.browseResult.itemKey
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)

    if itemKeyInfo then
      Auctionator.EventBus
        :RegisterSource(self, "exact mixin")
        :Fire(self, Auctionator.Search.Events.FilterComplete, self.browseResult, self:ExactMatchCheck(itemKeyInfo))
        :UnregisterSource(self)
        :Unregister(self, EXACT_EVENTS)
    end

  else
    Auctionator.EventBus
      :RegisterSource(self, "exact mixin")
      :Fire(self, Auctionator.Search.Events.FilterComplete, self.browseResult, true)
      :UnregisterSource(self)
      :Unregister(self, EXACT_EVENTS)
  end
end

function Auctionator.Search.Filters.ExactMixin:ReceiveEvent(eventName, blizzardName, itemID, ...)
  if eventName ~= Auctionator.Search.Events.BlizzardInfo then
    return
  end

  if blizzardName == "ITEM_KEY_ITEM_INFO_RECEIVED" and
     self.browseResult.itemKey.itemID == itemID then

    self:TryComplete()
  end
end

function Auctionator.Search.Filters.ExactMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.match)
end
