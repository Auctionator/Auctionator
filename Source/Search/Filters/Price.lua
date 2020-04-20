Auctionator.Search.Filters.PriceMixin = {}

function Auctionator.Search.Filters.PriceMixin:Init(browseResult, limits)
  self.limits = limits
  Auctionator.EventBus:RegisterSource(self, "price filter mixin")
    :Fire(self,
      Auctionator.Search.Events.FilterComplete,
      browseResult,
      self:PriceCheck(browseResult.minPrice)
    )
    :UnregisterSource(self)
end

function Auctionator.Search.Filters.PriceMixin:PriceCheck(price)
  return
    (
      --Minimum price check
      self.limits.min == nil or
      self.limits.min <= price
    ) and (
      --Maximum price check
      self.limits.max == nil or
      self.limits.max >= price
    )
end
