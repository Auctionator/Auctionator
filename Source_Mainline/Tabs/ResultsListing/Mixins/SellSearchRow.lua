AuctionatorSellSearchRowMixin = CreateFromMixins(AuctionatorResultsRowTemplateMixin)

local function BuyEntry(entry)
  Auctionator.EventBus
    :RegisterSource(BuyEntry, "BuyEntry")
    :Fire(BuyEntry, Auctionator.Selling.Events.ShowConfirmPurchase, entry)
    :UnregisterSource(BuyEntry)
end

function AuctionatorSellSearchRowMixin:OnEnter()
  -- Process itemLink directly (as bug in Blizz code prevents potions with a
  -- quality rating having their tooltip show)
  if self.rowData.itemLink then
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if Auctionator.Utilities.IsPetLink(self.rowData.itemLink) then
      BattlePetToolTip_ShowLink(self.rowData.itemLink)
    else
      GameTooltip:SetHyperlink(self.rowData.itemLink)
      GameTooltip:Show()
    end
  end
  AuctionatorResultsRowTemplateMixin.OnEnter(self)
end

function AuctionatorSellSearchRowMixin:OnLeave()
  if self.rowData.itemLink then
    if Auctionator.Utilities.IsPetLink(self.rowData.itemLink) then
      BattlePetTooltip:Hide()
    else
      GameTooltip:Hide()
    end
  end
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
