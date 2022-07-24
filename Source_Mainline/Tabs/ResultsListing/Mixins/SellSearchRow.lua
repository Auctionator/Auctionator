AuctionatorSellSearchRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

local function BuyEntry(entry)
  if entry.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
    C_AuctionHouse.StartCommoditiesPurchase(entry.itemID, entry.quantity)
  end
  Auctionator.EventBus
    :RegisterSource(BuyEntry, "BuyEntry")
    :Fire(BuyEntry, Auctionator.Selling.Events.ConfirmCallback, entry)
    :UnregisterSource(BuyEntry)
end

function AuctionatorSellSearchRowMixin:OnEnter()
  AuctionHouseUtil.LineOnEnterCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function AuctionatorSellSearchRowMixin:OnLeave()
  AuctionHouseUtil.LineOnLeaveCallback(self, self.rowData)
  AuctionatorResultsRowTemplateMixin.OnLeave(self)
end

function AuctionatorSellSearchRowMixin:OnClick(button, ...)
  Auctionator.Debug.Message("AuctionatorSellSearchRowMixin:OnClick()")

  if Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT), button) then
    if C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
      Auctionator.EventBus
        :RegisterSource(self, "SellSearchRow")
        :Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.rowData.auctionID)
        :UnregisterSource(self)
    end

  elseif Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BUY_SHORTCUT), button) then
    if self.rowData.canBuy then
      BuyEntry(self.rowData)
    end

  elseif IsModifiedClick("DRESSUP") then
    DressUpLink(self.rowData.itemLink);

  elseif IsModifiedClick("CHATLINK") then
    ChatEdit_InsertLink(self.rowData.itemLink)

  else
    Auctionator.EventBus
      :RegisterSource(self, "SellSearchRow")
      :Fire(self, Auctionator.Selling.Events.PriceSelected, self.rowData.price or self.rowData.bidPrice, true)
      :UnregisterSource(self)
  end
end
