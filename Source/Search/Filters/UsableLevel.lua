Auctionator.Search.Filters.UsableLevelMixin = {}

function Auctionator.Search.Filters.UsableLevelMixin:Init(filterTracker, browseResult, limits)
  self.limits = limits

  filterTracker:ReportFilterComplete(self:UsableLevelCheck(browseResult.itemKey))
end

function Auctionator.Search.Filters.UsableLevelMixin:UsableLevelCheck(itemKey)
  local usableLevel = C_AuctionHouse.GetItemKeyRequiredLevel(itemKey)

  return
    (
      --Minimum usable level check
      self.limits.min == nil or
      self.limits.min <= usableLevel
    ) and (
      --Maximum usable level check
      self.limits.max == nil or
      self.limits.max >= usableLevel
    )
end
