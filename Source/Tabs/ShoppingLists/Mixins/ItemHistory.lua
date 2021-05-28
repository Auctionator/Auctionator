AuctionatorItemHistoryFrameMixin = CreateFromMixins(AuctionatorEscapeToCloseMixin)

function AuctionatorItemHistoryFrameMixin:Init()
  self.DataProvider:Init(Auctionator.ShoppingLists.Events.ShowHistoricalPrices)
  self.ResultsListing:Init(self.DataProvider)

  Auctionator.EventBus:Register(self, { Auctionator.ShoppingLists.Events.ShowHistoricalPrices })
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

function AuctionatorItemHistoryFrameMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.ShoppingLists.Events.ShowHistoricalPrices then
    self.Title:SetText(AUCTIONATOR_L_X_PRICE_HISTORY:format(itemInfo.name))
  end
end

function AuctionatorItemHistoryFrameMixin:OnCloseDialogClicked()
  self:Hide()
end
