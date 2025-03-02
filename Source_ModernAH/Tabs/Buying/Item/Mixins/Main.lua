AuctionatorBuyItemFrameTemplateMixin = {}

function AuctionatorBuyItemFrameTemplateMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.ShowItemBuy,
    Auctionator.Shopping.Tab.Events.SearchStart,
  })

  self.ResultsListing:Init(self.DataProvider)
end

function AuctionatorBuyItemFrameTemplateMixin:OnShow()
  self:GetParent().ResultsListing:Hide()
  self:GetParent().ShoppingResultsInset:Hide()
  self:GetParent().ExportCSV:Hide()
end

function AuctionatorBuyItemFrameTemplateMixin:OnHide()
  self:GetParent().ResultsListing:Show()
  self:GetParent().ShoppingResultsInset:Show()
  self:GetParent().ExportCSV:Show()
  self:Hide()
end

function AuctionatorBuyItemFrameTemplateMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.Buying.Events.ShowItemBuy then
    local rowData, itemKeyInfo = ...

    self:Show()
    local prettyName = AuctionHouseUtil.GetItemDisplayTextFromItemKey(
      rowData.itemKey,
      itemKeyInfo,
      false
    )
    self.IconAndName:SetItem(rowData.itemKey, nil, itemKeyInfo.quality, prettyName, itemKeyInfo.iconFileID)
    self.IconAndName:SetScript("OnMouseUp", function()
      AuctionHouseFrame:SelectBrowseResult(rowData)
      -- Clear displayMode (prevents bag items breaking in some scenarios)
      AuctionHouseFrame.displayMode = nil
    end)

    local sortingOrder = Auctionator.Constants.ItemResultsSorts
    self.expectedItemKey = rowData.itemKey
    self:Search()
  elseif eventName == Auctionator.Shopping.Tab.Events.SearchStart then
    self:Hide()
  end
end

function AuctionatorBuyItemFrameTemplateMixin:Search()
  if not self.expectedItemKey then
    return
  end

  Auctionator.EventBus
    :RegisterSource(self, "BuyItemFrame")
    :Fire(self, Auctionator.Buying.Events.RefreshingItems)
    :UnregisterSource(self)
  local sortingOrder = Auctionator.Constants.ItemResultsSorts
  Auctionator.AH.SendSearchQueryByItemKey(self.expectedItemKey, {sortingOrder}, true)
end
