AuctionatorSellSearchRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorSellSearchRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function AuctionatorSellSearchRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function AuctionatorSellSearchRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorSellSearchRowMixin:OnClick()")

  Auctionator.EventBus
    :RegisterSource(self, "SellSearchRow")
    :Fire(self, Auctionator.Selling.Events.PriceSelected, self.rowData.price, true)
    :UnregisterSource(self)
end
