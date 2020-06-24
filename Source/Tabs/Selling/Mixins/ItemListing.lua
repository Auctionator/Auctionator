AuctionatorSellItemListingMixin = {}

local AUCTIONATOR_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED"
}

function AuctionatorSellItemListingMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
end

function AuctionatorSellItemListingMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
end