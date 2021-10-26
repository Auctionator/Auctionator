AuctionatorBuyDialogMixin = {}

local QUERY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

local EVENTS = {
  Auctionator.AH.Events.ThrottleUpdate,
}

local MONEY_EVENTS = {
  "PLAYER_MONEY"
}

function AuctionatorBuyDialogMixin:OnLoad()
  self.NumberPurchased:SetText(AUCTIONATOR_L_ALREADY_PURCHASED_X:format(15))
  self.PurchaseDetails:SetText(AUCTIONATOR_L_BUYING_X_FOR_X:format(BLUE_FONT_COLOR:WrapTextInColorCode("x20"), Auctionator.Utilities.CreateMoneyString(10998)))
  Auctionator.EventBus:RegisterSource(self, "BuyDialogMixin")

  self:Reset()
end

function AuctionatorBuyDialogMixin:Reset()
  self.auctionData = nil
  self.buyInfo = nil
  self.gotAllResults = true
  self.quantityPurchased = 0
end

function AuctionatorBuyDialogMixin:OnEvent(eventName)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  end
end

function AuctionatorBuyDialogMixin:OnShow()
  Auctionator.EventBus:Register(self, EVENTS)
  FrameUtil.RegisterFrameForEvents(self, MONEY_EVENTS)
end

function AuctionatorBuyDialogMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, MONEY_EVENTS)
  if self.quantityPurchased > 0 and self.auctionData ~= nil then
    Auctionator.Utilities.Message(AUCTIONATOR_L_PURCHASED_X_XX:format(self.auctionData.itemLink, self.quantityPurchased))
  end
  Auctionator.EventBus:Unregister(self, EVENTS)
  Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
  self.auctionData = nil
end

function AuctionatorBuyDialogMixin:UpdatePurchasedCount(newCount)
  if newCount == 0 then
    self.NumberPurchased:Hide()
  else
    self.NumberPurchased:Show()
  end

  self.NumberPurchased:SetText(AUCTIONATOR_L_ALREADY_PURCHASED_X:format(newCount))
end

function AuctionatorBuyDialogMixin:SetDetails(auctionData)
  self:Reset()

  self.auctionData = auctionData
  self:Show()

  if self.auctionData == nil then
    self:Hide()
    return
  end

  local stackText = BLUE_FONT_COLOR:WrapTextInColorCode("x" .. auctionData.stackSize)
  local priceText = Auctionator.Utilities.CreateMoneyString(auctionData.stackPrice)
  self.PurchaseDetails:SetText(AUCTIONATOR_L_BUYING_X_FOR_X:format(stackText, priceText))

  self:UpdatePurchasedCount(0)
  self:UpdateButtons()

  self:LoadForPurchasing()
end

function AuctionatorBuyDialogMixin:LoadForPurchasing()
  if self.auctionData.numStacks < 1 then
    self:UpdateButtons()
    return
  end

  Auctionator.AH.AbortQuery()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo == nil then
    Auctionator.EventBus:Register(self, QUERY_EVENTS)
    self.gotAllResults = false
    Auctionator.AH.QueryAndFocusPage(self.auctionData.query, self.auctionData.page)
  end

  self:UpdateButtons()
end

function AuctionatorBuyDialogMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdateButtons()
  elseif eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotAllResults = ...
    if self.gotAllResults then
      Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
    end
    if self.auctionData and self.auctionData.numStacks > 0 then
      self:FindAuctionOnCurrentPage()
      if self.buyInfo == nil then
        self:Hide()
        self:GetParent().SearchDataProvider:RefreshQuery()
      end
      self:UpdateButtons()
    end
  elseif eventName == Auctionator.AH.Events.ScanAborted then
    Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
  end
end

function AuctionatorBuyDialogMixin:FindAuctionOnCurrentPage()
  self.buyInfo = nil

  local page = Auctionator.AH.GetCurrentPage()
  for index, auction in ipairs(page) do
    local stackPrice = auction.info[Auctionator.Constants.AuctionItemInfo.Buyout]
    local stackSize = auction.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    local bidAmount = auction.info[Auctionator.Constants.AuctionItemInfo.BidAmount]
    if auction.itemLink == self.auctionData.itemLink and
       stackPrice == self.auctionData.stackPrice and
       stackSize == self.auctionData.stackSize and
       bidAmount ~= stackPrice then
      self.buyInfo = {index = index}
      break
    end
  end
end

function AuctionatorBuyDialogMixin:UpdateButtons()
  self.BuyStack:SetEnabled(self.auctionData ~= nil and Auctionator.AH.IsNotThrottled() and self.buyInfo ~= nil and self.auctionData.numStacks > 0 and GetMoney() >= self.auctionData.stackPrice)
  if self.auctionData and self.auctionData.numStacks > 0 then
    self.BuyStack:SetText(AUCTIONATOR_L_BUY_STACK)
  else
    self.BuyStack:SetText(AUCTIONATOR_L_NONE_LEFT)
  end
end

function AuctionatorBuyDialogMixin:BuyStackClicked()
  if self.auctionData.stackPrice > GetMoney() then
    self:UpdateButtons()
    return
  end

  self:FindAuctionOnCurrentPage()
  if self.buyInfo ~= nil then
    Auctionator.AH.PlaceAuctionBid(self.buyInfo.index, self.auctionData.stackPrice)
    self.auctionData.numStacks = self.auctionData.numStacks - 1
    Auctionator.Utilities.SetStacksText(self.auctionData)
    self.quantityPurchased = self.quantityPurchased + self.auctionData.stackSize
    self:UpdatePurchasedCount(self.quantityPurchased)
    Auctionator.EventBus:Fire(self, Auctionator.Buying.Events.StacksUpdated)
  end
  self:LoadForPurchasing()
end

