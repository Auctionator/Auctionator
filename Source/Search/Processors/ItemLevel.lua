Auctionator.Search.Processors.ItemLevelMixin = CreateFromMixins(Auctionator.Search.Processors.ProcessorMixin)


local function HasItemLevel(itemKey)
  -- Check for 0 is to avoid filtering issues with glitchy AH APIs.
  return itemKey.itemLevel ~= nil and itemKey.itemLevel ~= 0
end

function Auctionator.Search.Processors.ItemLevelMixin:LevelFilterSatisfied(itemKey)
  return
    (
      --Minimum item level check
      self.filter.min == nil or
      self.filter.min <= itemKey.itemLevel
    ) and (
      --Maximum item level check
      self.filter.max == nil or
      self.filter.max >= itemKey.itemLevel
    )
end

function Auctionator.Search.Processors.ItemLevelMixin:TryComplete()
  local itemKey = self.browseResult.itemKey
  self:PostComplete((not HasItemLevel(itemKey)) or self:LevelFilterSatisfied(itemKey))
end
