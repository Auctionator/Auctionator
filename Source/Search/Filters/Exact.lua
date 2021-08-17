-- Exact search terms
Auctionator.Search.Filters.ExactMixin = {}

function Auctionator.Search.Filters.ExactMixin:Init(browseResult, match)
  self.match = match
  
  Auctionator.AH.GetItemKeyInfo(browseResult.itemKey, function(itemKeyInfo)
    Auctionator.EventBus
      :RegisterSource(self, "exact mixin")
      :Fire(self, Auctionator.Search.Events.FilterComplete, browseResult, self:ExactMatchCheck(itemKeyInfo))
      :UnregisterSource(self)
  end)
end

function Auctionator.Search.Filters.ExactMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.match)
end
