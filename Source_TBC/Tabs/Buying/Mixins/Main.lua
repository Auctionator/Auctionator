local MONEY_EVENTS = {
  "PLAYER_MONEY"
}

AuctionatorBuyFrameMixin = {}

function AuctionatorBuyFrameMixin:Init()
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.Buying.Events.StacksUpdated,
    Auctionator.AH.Events.ThrottleUpdate,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorBuyFrameMixin")
  self.SearchResultsListing:Init(self.SearchDataProvider)
  self.HistoryResultsListing:Init(self.HistoryDataProvider)
  self.selectedAuctionData = nil
  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:Reset()
  self.selectedAuctionData = nil
  self.SearchDataProvider:Reset()
  self.HistoryDataProvider:Reset()

  if self.HistoryResultsListing:IsShown() then
    self:ToggleHistory()
  end
  self.BuyDialog:Hide()

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, MONEY_EVENTS)
end

function AuctionatorBuyFrameMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, MONEY_EVENTS)
end

function AuctionatorBuyFrameMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  end
end

function AuctionatorBuyFrameMixin:ReceiveEvent(eventName, eventData, ...)
  if self:IsVisible() and eventName == Auctionator.Buying.Events.AuctionFocussed then
    self.selectedAuctionData = eventData
    if self.selectedAuctionData and self.selectedAuctionData.isOwned then
      self:LoadForCancelling()
    end
    self:UpdateButtons()
  elseif self:IsVisible() and eventName == Auctionator.Buying.Events.StacksUpdated then
    if self.selectedAuctionData and self.selectedAuctionData.numStacks == 0 then
      self.selectedAuctionData.isSelected = false
      self.selectedAuctionData = nil
    end
  elseif self:IsVisible() and eventName == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdateButtons()
  end
end

function AuctionatorBuyFrameMixin:UpdateButtons()
  self.CancelButton:SetEnabled(self.selectedAuctionData ~= nil and self.selectedAuctionData.isOwned and self.selectedAuctionData.numStacks > 0 and Auctionator.AH.IsNotThrottled())
  self.BuyButton:Disable()

  self.BuyButton:SetEnabled(self.selectedAuctionData ~= nil and not self.selectedAuctionData.isOwned and GetMoney() >= self.selectedAuctionData.stackPrice)
end

function AuctionatorBuyFrameMixin:GetOwnerAuctionIndex()
  local auction = self.selectedAuctionData

  local indexes = {}
  for index = 1, GetNumAuctionItems("owner") do
    local info = { GetAuctionItemInfo("owner", index) }

    local stackPrice = info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local isOwned = info[Auctionator.Constants.AuctionItemInfo.Owner] == (GetUnitName("player"))
    local saleStatus = info[Auctionator.Constants.AuctionItemInfo.SaleStatus]
    local itemLink = GetAuctionItemLink("owner", index)

    if saleStatus ~= 1 and auction.stackPrice == stackPrice and auction.stackSize == stackSize and isOwned and Auctionator.Search.GetCleanItemLink(itemLink) == Auctionator.Search.GetCleanItemLink(auction.itemLink) then
      table.insert(indexes, index)
    end
  end

  return indexes
end

function AuctionatorBuyFrameMixin:LoadForCancelling()
  if self.selectedAuctionData.numStacks < 1 then
    self.selectedAuctionData.isSelected = false
    self.selectedAuctionData = nil
    self:UpdateButtons()
    return
  end

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:ToggleHistory()
  self.HistoryResultsListing:SetShown(not self.HistoryResultsListing:IsShown())
  self.SearchResultsListing:SetShown(not self.SearchResultsListing:IsShown())
  if self.HistoryResultsListing:IsShown() then
    self.HistoryButton:SetText(AUCTIONATOR_L_CURRENT)
  else
    self.HistoryButton:SetText(AUCTIONATOR_L_HISTORY)
  end
end

function AuctionatorBuyFrameMixin:CancelFocussed()
  local indexes = self:GetOwnerAuctionIndex()
  if #indexes == 0 then
    if #indexes < self.selectedAuctionData.numStacks then
      Auctionator.Utilities.Message(AUCTIONATOR_L_ERROR_REOPEN_AUCTION_HOUSE)
    end
    self:Reset()
    self.SearchDataProvider:RefreshQuery()
  else
    Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.selectedAuctionData)
    self.selectedAuctionData.numStacks = self.selectedAuctionData.numStacks - 1
    Auctionator.Utilities.SetStacksText(self.selectedAuctionData)
  end
  self:LoadForCancelling()
end

function AuctionatorBuyFrameMixin:BuyClicked()
  self.BuyDialog:SetDetails(self.selectedAuctionData)
end


AuctionatorBuyFrameMixinForShopping = CreateFromMixins(AuctionatorBuyFrameMixin)

function AuctionatorBuyFrameMixinForShopping:Init()
  AuctionatorBuyFrameMixin.Init(self)
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.Show,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
  })
end

function AuctionatorBuyFrameMixinForShopping:OnShow()
  AuctionatorBuyFrameMixin.OnShow(self)

  self:GetParent().ResultsListing:Hide()
  self:GetParent().ExportCSV:Hide()
  self:GetParent().ShoppingResultsInset:Hide()
end

function AuctionatorBuyFrameMixinForShopping:OnHide()
  AuctionatorBuyFrameMixin.OnHide(self)

  self:Hide()

  self:GetParent().ResultsListing:Show()
  self:GetParent().ExportCSV:Show()
  self:GetParent().ShoppingResultsInset:Show()
end

function AuctionatorBuyFrameMixinForShopping:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Buying.Events.Show then
    self:Show()

    self:Reset()

    if #eventData.entries > 0 then
      self.SearchDataProvider:SetQuery(eventData.entries[1].itemLink)
      self.HistoryDataProvider:SetItemLink(eventData.entries[1].itemLink)
    else
      self.SearchDataProvider:SetQuery(nil)
      self.HistoryDataProvider:SetItemLink(nil)
    end
    self.SearchDataProvider:SetAuctions(eventData.entries)
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Hide()
  else
    AuctionatorBuyFrameMixin.ReceiveEvent(self, eventName, eventData, ...)
  end
end

AuctionatorBuyFrameMixinForSelling = CreateFromMixins(AuctionatorBuyFrameMixin)

function AuctionatorBuyFrameMixinForSelling:Init()
  AuctionatorBuyFrameMixin.Init(self)
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RefreshBuying,
  })
end

function AuctionatorBuyFrameMixinForSelling:OnShow()
  self:Reset()
  self.RefreshButton:Disable()
  self.HistoryButton:Disable()
end

function AuctionatorBuyFrameMixinForSelling:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Selling.Events.RefreshBuying then
    self:Reset()

    self.HistoryDataProvider:SetItemLink(eventData.itemLink)
    self.SearchDataProvider:SetQuery(eventData.itemLink)
    self.SearchDataProvider:SetRequestAllResults(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SHOW_ALL_RESULTS))
    self.SearchDataProvider:RefreshQuery()

    self.RefreshButton:Enable()
    self.HistoryButton:Enable()
  else
    AuctionatorBuyFrameMixin.ReceiveEvent(self, eventName, eventData, ...)
  end
end
