-- Exact search terms
Auctionator.Search.Filters.ExactMixin = {}

function Auctionator.Search.Filters.ExactMixin:Init(filterTracker, browseResult, match)
  self.match = match
  
  Auctionator.AH.GetItemKeyInfo(browseResult.itemKey, function(itemKeyInfo)
    filterTracker:ReportFilterComplete(self:ExactMatchCheck(itemKeyInfo))
  end)
end

function Auctionator.Search.Filters.ExactMixin:ExactMatchCheck(itemKeyInfo)
  return string.lower(itemKeyInfo.itemName) == string.lower(self.match)
end
