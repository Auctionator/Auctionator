-- Exact search terms
Auctionator.Search.Filters.ExactMixin = {}

local EXACT_EVENTS = {
  Auctionator.AH.Events.ItemKeyInfo
}

function Auctionator.Search.Filters.ExactMixin:Init(browseResult, match)
  Auctionator.EventBus:Register(self, EXACT_EVENTS)

  self.browseResult = browseResult
  self.match = match
  
  if self.match ~= nil then
    Auctionator.AH.GetItemKeyInfo(self.browseResult.itemKey)
  else
    Auctionator.EventBus
      :RegisterSource(self, "exact mixin")
      :Fire(self, Auctionator.Search.Events.FilterComplete, self.browseResult, true)
      :UnregisterSource(self)
      :Unregister(self, EXACT_EVENTS)
  end
end

function Auctionator.Search.Filters.ExactMixin:ReceiveEvent(eventName, itemKey, itemKeyInfo)
  if Auctionator.Utilities.ItemKeyString(self.browseResult.itemKey) ==
      Auctionator.Utilities.ItemKeyString(itemKey) then
    Auctionator.EventBus
      :RegisterSource(self, "exact mixin")
      :Fire(self, Auctionator.Search.Events.FilterComplete, self.browseResult, self:ExactMatchCheck(itemKeyInfo))
      :UnregisterSource(self)
      :Unregister(self, EXACT_EVENTS)
  end
end

function Auctionator.Search.Filters.ExactMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.match)
end
