Auctionator.Search.Filters.BlankFilterMixin = {}

function Auctionator.Search.Filters.BlankFilterMixin:Init(browseResult)
  Auctionator.EventBus
    :RegisterSource(self, "Blank Search Filter")
    :Fire(self, Auctionator.Search.Events.FilterComplete, browseResult, true)
    :UnregisterSource(self)
end
