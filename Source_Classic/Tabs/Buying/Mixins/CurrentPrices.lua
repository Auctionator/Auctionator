local BUY_EVENTS = {
  "PLAYER_MONEY",
  "AUCTION_OWNED_LIST_UPDATE"
}

AuctionatorBuyCurrentPricesFrameMixin = {}

function AuctionatorBuyCurrentPricesFrameMixin:Init()
  Auctionator.EventBus:RegisterSource(self, "AuctionatorBuyCurrentPricesFrameMixin")
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.Buying.Events.StacksUpdated,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.AH.Events.ScanResultsUpdate,
  })
  self.SearchResultsListing:Init(self.SearchDataProvider)
  self.selectedAuctionData = nil
  self:UpdateButtons()
end

function AuctionatorBuyCurrentPricesFrameMixin:Reset()
  self.selectedAuctionData = nil
  self.lastCancelData = nil
  self.gotCompleteResults = true
  self.SearchDataProvider.onSearchEnded()
  self.SearchDataProvider:Reset()
  self.loadAllPagesPending = false

  self.BuyDialog:Hide()

  self:UpdateButtons()
end

function AuctionatorBuyCurrentPricesFrameMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BUY_EVENTS)
  self.LoadAllPagesButton:Hide()
  self.StopLoadingNowButton:Hide()
  self:UpdateButtons()
end

function AuctionatorBuyCurrentPricesFrameMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BUY_EVENTS)
  self.SearchDataProvider:EndAnyQuery()
end

local function CountOwnedAuctions(auctionType)
  local allAuctions = Auctionator.AH.DumpAuctions("owner")

  local runningTotal = 0

  for _, auction in ipairs(allAuctions) do
    local stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local isSold = auction.info[Auctionator.Constants.AuctionItemInfo.SaleStatus] == 1
    if not isSold and stackPrice == auctionType.stackPrice and stackSize == auctionType.stackSize and auction.itemLink == auctionType.itemLink then
      runningTotal = runningTotal + 1
    end
  end

  return runningTotal
end

function AuctionatorBuyCurrentPricesFrameMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  elseif eventName == "AUCTION_OWNED_LIST_UPDATE" and self.lastCancelData ~= nil then
    -- Determine how many of the auction are left after an attempted
    -- cancellation
    self.lastCancelData.numStacks = CountOwnedAuctions(self.lastCancelData)
    Auctionator.Utilities.SetStacksText(self.lastCancelData)
    if self.lastCancelData.numStacks == 0 then
      Auctionator.EventBus:Fire(self, Auctionator.Buying.Events.AuctionFocussed, nil)
    end
    self.lastCancelData = nil
    self.SearchDataProvider:SetDirty()
  end
end

function AuctionatorBuyCurrentPricesFrameMixin:UpdateButtons()
  self.CancelButton:SetEnabled(self.selectedAuctionData ~= nil and self.selectedAuctionData.isOwned and self.selectedAuctionData.numStacks > 0 and Auctionator.AH.IsNotThrottled())
  self.BuyButton:Disable()

  self.BuyButton:SetEnabled(self.selectedAuctionData ~= nil and not self.selectedAuctionData.isOwned and self.selectedAuctionData.stackPrice ~= nil and GetMoney() >= self.selectedAuctionData.stackPrice)

  self.LoadAllPagesButton:SetShown(not self.SearchDataProvider:GetRequestAllResults() and not self.gotCompleteResults and self.SearchResultsListing:IsShown())
  self.StopLoadingNowButton:SetShown(self.loadAllPagesPending and not self.SearchDataProvider:HasAllQueriedResults() and self.SearchResultsListing:IsShown())
end

function AuctionatorBuyCurrentPricesFrameMixin:ReceiveEvent(eventName, eventData, ...)
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
  elseif self:IsVisible() and eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotCompleteResults = ...
    self:UpdateButtons()
  end
end

function AuctionatorBuyCurrentPricesFrameMixin:GetOwnerAuctionIndex()
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

function AuctionatorBuyCurrentPricesFrameMixin:CancelFocussed()
  local indexes = self:GetOwnerAuctionIndex()
  if #indexes == 0 then
    if #indexes < self.selectedAuctionData.numStacks then
      Auctionator.Utilities.Message(AUCTIONATOR_L_ERROR_REOPEN_AUCTION_HOUSE)
    end
    self:Reset()
    self:DoRefresh()
  else
    Auctionator.EventBus:Fire(self, Auctionator.Cancelling.Events.RequestCancel, self.selectedAuctionData)
  end
  self.lastCancelData = self.selectedAuctionData --Used to set amount left after cancelling
  self:LoadForCancelling()
end

function AuctionatorBuyCurrentPricesFrameMixin:LoadForCancelling()
  if self.selectedAuctionData ~= nil and self.selectedAuctionData.numStacks < 1 then
    self.selectedAuctionData.isSelected = false
    self.selectedAuctionData = nil
    self:UpdateButtons()
    return
  end

  self:UpdateButtons()
end

function AuctionatorBuyCurrentPricesFrameMixin:DoRefresh()
  self.SearchDataProvider:SetRequestAllResults(false)
  self.SearchDataProvider:RefreshQuery()
  self.loadAllPagesPending = false
end

function AuctionatorBuyCurrentPricesFrameMixin:BuyClicked()
  self.BuyDialog:SetDetails(self.selectedAuctionData)
end

function AuctionatorBuyCurrentPricesFrameMixin:LoadAllPages()
  self.SearchDataProvider:SetRequestAllResults(true)
  self.LoadAllPagesButton:Hide()
  self.StopLoadingNowButton:Show()
  self.loadAllPagesPending = true

  self.SearchDataProvider:RefreshQuery()
end

function AuctionatorBuyCurrentPricesFrameMixin:StopLoadingPages()
  self.SearchDataProvider:SetRequestAllResults(false)
  self.LoadAllPagesButton:Show()
  self.StopLoadingNowButton:Hide()
  self.loadAllPagesPending = false

  self.SearchDataProvider:EndAnyQuery()
end
