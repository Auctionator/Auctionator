AuctionatorCancellingListResultsRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

function AuctionatorCancellingListResultsRowMixin:OnClick(...)
  Auctionator.Debug.Message("AuctionatorCancellingListResultsRowMixin:OnClick", self.rowData and self.rowData.id)

  self.rowData.cancelled = true
  self:ApplyFade()

  Auctionator.EventBus
    :RegisterSource(self, "CancellingListResultRow")
    :Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.rowData.id)
    :UnregisterSource(self)
end

function AuctionatorCancellingListResultsRowMixin:Populate(rowData, dataIndex)
  AuctionatorResultsRowTemplateMixin.Populate(self, rowData, dataIndex)

  self:ApplyFade()
end

function AuctionatorCancellingListResultsRowMixin:ApplyFade()
  --Fade while waiting for the cancel to take effect
  if self.rowData.cancelled then
    self:SetAlpha(0.5)
  else
    self:SetAlpha(1)
  end
end
