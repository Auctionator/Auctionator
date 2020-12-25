AuctionatorItemHistoryFrameMixin = CreateFromMixins(AuctionatorEscapeToCloseMixin)

function AuctionatorItemHistoryFrameMixin:Init()
  self.DataProvider:Init(Auctionator.ShoppingLists.Events.ShowHistoricalPrices)
  self.ResultsListing:Init(self.DataProvider)
end

function AuctionatorItemHistoryFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorItemHistoryFrameMixin:OnShow()")

  Auctionator.EventBus
    :RegisterSource(self, "lists item history dialog")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogOpened)
    :UnregisterSource(self)
end

function AuctionatorItemHistoryFrameMixin:OnHide()
  self:Hide()

  Auctionator.EventBus
    :RegisterSource(self, "lists item history 1")
    :Fire(self, Auctionator.ShoppingLists.Events.DialogClosed)
    :UnregisterSource(self)
end

function AuctionatorItemHistoryFrameMixin:OnCloseDialogClicked()
  self:Hide()
end
