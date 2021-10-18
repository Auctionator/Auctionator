AuctionatorBuyFrameMixin = {}

local QUERY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

function AuctionatorBuyFrameMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.AH.Events.ThrottleUpdate,
  })
  self.SearchResultsListing:Init(self.SearchDataProvider)
  self.HistoryResultsListing:Init(self.HistoryDataProvider)
  self.selectedAuctionData = nil
  self.buyInfo = nil
  self.gotAllResults = true
  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:Reset()
  self.selectedAuctionData = nil
  self.buyInfo = nil
  self.SearchDataProvider:Reset()
  self.HistoryDataProvider:Reset()

  if self.HistoryResultsListing:IsShown() then
    self:ToggleHistory()
  end

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:ReceiveEvent(eventName, eventData, ...)
  if self:IsVisible() and eventName == Auctionator.Buying.Events.AuctionFocussed then
    self.selectedAuctionData = eventData
    self.buyInfo = nil
    if self.selectedAuctionData then
      if eventData.isOwned then
        self:LoadForCancelling()
      else
        self:LoadForPurchasing()
      end
    end
    self:UpdateButtons()
  elseif self:IsVisible() and eventName == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdateButtons()
  elseif eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotAllResults = ...
    if self.gotAllResults then
      Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
    end
    if self.selectedAuctionData and not self.selectedAuctionData.isOwned then
      self:FindAuctionOnCurrentPage()
      if self.buyInfo == nil then
        self:Reset()
        self.SearchDataProvider:RefreshQuery()
      end
      self:UpdateButtons()
    end
  elseif eventName == Auctionator.AH.Events.ScanAborted then
    Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
  end
end

function AuctionatorBuyFrameMixin:UpdateButtons()
  self.CancelButton:SetEnabled(self.selectedAuctionData ~= nil and self.selectedAuctionData.isOwned and self.selectedAuctionData.noOfStacks > 0 and Auctionator.AH.IsNotThrottled())
  self.BuyButton:Disable()

  self.BuyButton:SetEnabled(self.selectedAuctionData ~= nil and self.buyInfo ~= nil and Auctionator.AH.IsNotThrottled())
end

function AuctionatorBuyFrameMixin:FindAuctionOnCurrentPage()
  self.buyInfo = nil

  local page = Auctionator.AH.GetCurrentPage()
  for index, auction in ipairs(page) do
    local stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount]
    if auction.itemLink == self.selectedAuctionData.itemLink and
       stackPrice == self.selectedAuctionData.stackPrice and
       stackSize == self.selectedAuctionData.stackSize and
       bidAmount ~= stackPrice then
      self.buyInfo = {index = index}
      break
    end
  end
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
  if self.selectedAuctionData.noOfStacks < 1 then
    self.selectedAuctionData.isSelected = false
    self.selectedAuctionData = nil
    self:UpdateButtons()
    return
  end

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:LoadForPurchasing()
  if self.selectedAuctionData.noOfStacks < 1 then
    self.selectedAuctionData.isSelected = false
    self.selectedAuctionData = nil
    self:UpdateButtons()
    return
  end

  Auctionator.AH.AbortQuery()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo == nil then
    Auctionator.EventBus:Register(self, QUERY_EVENTS)
    self.gotAllResults = false
    Auctionator.AH.QueryAndFocusPage(self.selectedAuctionData.query, self.selectedAuctionData.page)
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
    if #indexes < self.selectedAuctionData.noOfStacks then
      Auctionator.Utilities.Message(AUCTIONATOR_L_ERROR_REOPEN_AUCTION_HOUSE)
    end
    self:Reset()
    self.SearchDataProvider:RefreshQuery()
  else
    Auctionator.AH.CancelAuction(self.selectedAuctionData)
    self.selectedAuctionData.noOfStacks = self.selectedAuctionData.noOfStacks - 1
  end
  self:LoadForCancelling()
end

function AuctionatorBuyFrameMixin:BuyFocussed()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo ~= nil then
    Auctionator.AH.PlaceAuctionBid(self.buyInfo.index, self.selectedAuctionData.stackPrice)
    self.selectedAuctionData.noOfStacks = self.selectedAuctionData.noOfStacks - 1
  end
  self:LoadForPurchasing()
end


AuctionatorBuyFrameMixinForShopping = CreateFromMixins(AuctionatorBuyFrameMixin)

function AuctionatorBuyFrameMixinForShopping:OnLoad()
  AuctionatorBuyFrameMixin.OnLoad(self)
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.Show,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
  })
end

function AuctionatorBuyFrameMixinForShopping:OnShow()
  self:GetParent().ResultsListing:Hide()
  self:GetParent().ExportCSV:Hide()
  self:GetParent().ShoppingResultsInset:Hide()
end

function AuctionatorBuyFrameMixinForShopping:OnHide()
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

function AuctionatorBuyFrameMixinForSelling:OnLoad()
  AuctionatorBuyFrameMixin.OnLoad(self)
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
  if eventName == Auctionator.Selling.Events.BagItemClicked or
     eventName == Auctionator.Selling.Events.RefreshBuying then
    self:Reset()

    self.HistoryDataProvider:SetItemLink(eventData.itemLink)
    self.SearchDataProvider:SetQuery(eventData.itemLink)
    self.SearchDataProvider:RefreshQuery()

    self.RefreshButton:Enable()
    self.HistoryButton:Enable()
  else
    AuctionatorBuyFrameMixin.ReceiveEvent(self, eventName, eventData, ...)
  end
end
