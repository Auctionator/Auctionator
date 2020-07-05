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

  if (Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SHIFT_CANCEL) and
      IsShiftKeyDown()) then
    if C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
      Auctionator.EventBus
        :RegisterSource(self, "SellSearchRow")
        :Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.rowData.auctionID)
        :UnregisterSource(self)
    end

  else
    Auctionator.EventBus
      :RegisterSource(self, "SellSearchRow")
      :Fire(self, Auctionator.Selling.Events.PriceSelected, self.rowData.price, true)
      :UnregisterSource(self)
  end
end
