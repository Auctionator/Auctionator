AuctionatorSellCommodityListingMixin = {}

local AUCTIONATOR_COMMODITY_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED"
}

function AuctionatorSellCommodityListingMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
end

function AuctionatorSellCommodityListingMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
end