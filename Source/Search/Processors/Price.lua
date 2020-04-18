Auctionator.Search.Processors.PriceMixin = CreateFromMixins(Auctionator.Search.Processors.ProcessorMixin)


function Auctionator.Search.Processors.PriceMixin:PriceRangeSatisfied(browseResult)
  return
    (
      --Minimum item level check
      self.filter.min == nil or
      self.filter.min <= browseResult.minPrice
    ) and (
      --Maximum item level check
      self.filter.max == nil or
      self.filter.max >= browseResult.minPrice
    )
end

function Auctionator.Search.Processors.PriceMixin:TryComplete()
  self:PostComplete(self:PriceRangeSatisfied(self.browseResult))
end
