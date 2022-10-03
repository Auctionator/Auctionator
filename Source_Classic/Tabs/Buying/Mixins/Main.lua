local BUY_EVENTS = {
  "PLAYER_MONEY",
  "AUCTION_OWNED_LIST_UPDATE"
}

AuctionatorBuyFrameMixin = {}

function AuctionatorBuyFrameMixin:Init()
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.AuctionFocussed,
    Auctionator.Buying.Events.StacksUpdated,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.AH.Events.ScanResultsUpdate,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorBuyFrameMixin")
  self.SearchResultsListing:Init(self.SearchDataProvider)
  self.HistoryResultsListing:Init(self.HistoryDataProvider)
  self.selectedAuctionData = nil
  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:Reset()
  self.selectedAuctionData = nil
  self.lastCancelData = nil
  self.gotCompleteResults = true
  self.SearchDataProvider.onSearchEnded()
  self.SearchDataProvider:Reset()
  self.HistoryDataProvider:Reset()

  if self.HistoryResultsListing:IsShown() then
    self:ToggleHistory()
  end
  self.BuyDialog:Hide()

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, BUY_EVENTS)
  self.LoadAllPagesButton:Hide()
end

function AuctionatorBuyFrameMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, BUY_EVENTS)
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

function AuctionatorBuyFrameMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  elseif eventName == "AUCTION_OWNED_LIST_UPDATE" and self.lastCancelData ~= nil then
    -- Determine how many of the auction are left after an attempted
    -- cancellation
    self.lastCancelData.numStacks = CountOwnedAuctions(self.lastCancelData)
    Auctionator.Utilities.SetStacksText(self.lastCancelData)
    self.lastCancelData = nil
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
  elseif self:IsVisible() and eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotCompleteResults = ...
    self:UpdateButtons()
  end
end

function AuctionatorBuyFrameMixin:UpdateButtons()
  self.CancelButton:SetEnabled(self.selectedAuctionData ~= nil and self.selectedAuctionData.isOwned and self.selectedAuctionData.numStacks > 0 and Auctionator.AH.IsNotThrottled())
  self.BuyButton:Disable()

  self.BuyButton:SetEnabled(self.selectedAuctionData ~= nil and not self.selectedAuctionData.isOwned and self.selectedAuctionData.stackPrice ~= nil and GetMoney() >= self.selectedAuctionData.stackPrice)

  self.LoadAllPagesButton:SetShown(not self.SearchDataProvider:GetRequestAllResults() and not self.gotCompleteResults and self.SearchResultsListing:IsShown())
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
  if self.selectedAuctionData ~= nil and self.selectedAuctionData.numStacks < 1 then
    self.selectedAuctionData.isSelected = false
    self.selectedAuctionData = nil
    self:UpdateButtons()
    return
  end

  self:UpdateButtons()
end

function AuctionatorBuyFrameMixin:LoadAllPages()
  self.SearchDataProvider:SetRequestAllResults(true)
  self.LoadAllPagesButton:Hide()
  self.SearchDataProvider:RefreshQuery()
end

function AuctionatorBuyFrameMixin:ToggleHistory()
  self.HistoryResultsListing:SetShown(not self.HistoryResultsListing:IsShown())
  self.SearchResultsListing:SetShown(not self.SearchResultsListing:IsShown())
  if self.HistoryResultsListing:IsShown() then
    self.HistoryButton:SetText(AUCTIONATOR_L_CURRENT)
  else
    self.HistoryButton:SetText(AUCTIONATOR_L_HISTORY)
  end
  self:UpdateButtons()
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
  end
  self.lastCancelData = self.selectedAuctionData --Used to set amount left after cancelling
  self:LoadForCancelling()
end

function AuctionatorBuyFrameMixin:BuyClicked()
  self.BuyDialog:SetDetails(self.selectedAuctionData)
end


AuctionatorBuyFrameMixinForShopping = CreateFromMixins(AuctionatorBuyFrameMixin)

function AuctionatorBuyFrameMixinForShopping:Init()
  AuctionatorBuyFrameMixin.Init(self)
  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.ShowForShopping,
    Auctionator.Shopping.Events.ListSearchStarted,
  })
end

function AuctionatorBuyFrameMixinForShopping:OnShow()
  AuctionatorBuyFrameMixin.OnShow(self)

  self:GetParent().ResultsListing:Hide()
  self:GetParent().ExportCSV:Hide()
  self:GetParent().ShoppingResultsInset:Hide()
  self.wasParentLoadAllPagesVisible = self:GetParent().LoadAllPagesButton:IsShown()
  self:GetParent().LoadAllPagesButton:Hide()
end

function AuctionatorBuyFrameMixinForShopping:OnHide()
  AuctionatorBuyFrameMixin.OnHide(self)

  self:Hide()

  self:GetParent().ResultsListing:Show()
  self:GetParent().ExportCSV:Show()
  self:GetParent().ShoppingResultsInset:Show()
  self:GetParent().LoadAllPagesButton:SetShown(self.wasParentLoadAllPagesVisible)
end

function AuctionatorBuyFrameMixinForShopping:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Buying.Events.ShowForShopping then
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

    self.SearchDataProvider:SetRequestAllResults(eventData.complete)
    if not eventData.complete and #eventData.entries < Auctionator.Constants.MaxResultsPerPage then
      self.SearchDataProvider:RefreshQuery()
    else
      self.gotCompleteResults = eventData.complete
      self:UpdateButtons()
    end
  elseif eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self:Hide()
  else
    AuctionatorBuyFrameMixin.ReceiveEvent(self, eventName, eventData, ...)
  end
end

AuctionatorBuyFrameMixinForSelling = CreateFromMixins(AuctionatorBuyFrameMixin)

function AuctionatorBuyFrameMixinForSelling:Init()
  AuctionatorBuyFrameMixin.Init(self)
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.RefreshBuying,
    Auctionator.Selling.Events.StartFakeBuyLoading,
    Auctionator.Selling.Events.StopFakeBuyLoading,
    Auctionator.Selling.Events.AuctionCreated,
  })
end

function AuctionatorBuyFrameMixinForSelling:Reset()
  AuctionatorBuyFrameMixin.Reset(self)

  self.waitingOnNewAuction = false
end

function AuctionatorBuyFrameMixinForSelling:OnShow()
  AuctionatorBuyFrameMixin.OnShow(self)
  self:Reset()
  self.RefreshButton:Disable()
  self.HistoryButton:Disable()
end

function AuctionatorBuyFrameMixinForSelling:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Selling.Events.RefreshBuying then
    self:Reset()

    self.HistoryDataProvider:SetItemLink(eventData.itemLink)
    self.SearchDataProvider:SetQuery(eventData.itemLink)
    self.SearchDataProvider:SetRequestAllResults(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ALWAYS_LOAD_MORE))
    self.SearchDataProvider:RefreshQuery()

    self.RefreshButton:Enable()
    self.HistoryButton:Enable()
  elseif eventName == Auctionator.Selling.Events.StartFakeBuyLoading then
    -- Used so that it is clear something is loading, even if the search can't
    -- be sent yet.
    self.HistoryDataProvider:SetItemLink(eventData.itemLink)
    self.SearchDataProvider:SetQuery(eventData.itemLink)
    self.SearchDataProvider.onSearchStarted()
  elseif eventName == Auctionator.Selling.Events.StopFakeBuyLoading then
    self.SearchDataProvider.onSearchEnded()
    self:Reset()
    self.RefreshButton:Disable()
    self.HistoryButton:Disable()
  elseif eventName == Auctionator.Selling.Events.AuctionCreated then
    self.waitingOnNewAuction = true
  else
    AuctionatorBuyFrameMixin.ReceiveEvent(self, eventName, eventData, ...)
  end
end

function AuctionatorBuyFrameMixinForSelling:OnEvent(eventName, ...)
  AuctionatorBuyFrameMixin.OnEvent(self, eventName, ...)

  if eventName == "AUCTION_OWNED_LIST_UPDATE" and self.waitingOnNewAuction then
    self.waitingOnNewAuction = false
    self.SearchDataProvider:PurgeAndReplaceOwnedAuctions(Auctionator.AH.DumpAuctions("owner"))
  end
end
