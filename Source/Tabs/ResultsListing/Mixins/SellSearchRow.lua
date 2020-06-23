AuctionatorSellSearchRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorSellSearchRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function AuctionatorSellSearchRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end
