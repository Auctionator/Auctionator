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
  self:RegisterForDrag("LeftButton")
  self.NumberPurchased:SetText(AUCTIONATOR_L_ALREADY_PURCHASED_X:format(15))
  self.PurchaseDetails:SetText(AUCTIONATOR_L_BUYING_X_FOR_X:format(BLUE_FONT_COLOR:WrapTextInColorCode("x20"), Auctionator.Utilities.CreateMoneyString(10998)))
  self.UnitPrice:SetText(AUCTIONATOR_L_BRACKETS_X_EACH:format(Auctionator.Utilities.CreateMoneyString(550)))
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
  self.ChainBuy:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CHAIN_BUY_STACKS))
  self.PriceWarning:Hide()
end

function AuctionatorBuyDialogMixin:OnHide()
  self:SetChainBuy()
  FrameUtil.UnregisterFrameForEvents(self, MONEY_EVENTS)
  if self.quantityPurchased > 0 and self.auctionData ~= nil then
    Auctionator.Utilities.Message(AUCTIONATOR_L_PURCHASED_X_XX:format(self.auctionData.itemLink, self.quantityPurchased))
  end
  Auctionator.EventBus:Unregister(self, EVENTS)
  Auctionator.EventBus:Unregister(self, QUERY_EVENTS)
  self.auctionData = nil

  if self.priceWarningTimeout then
    self.priceWarningTimeout:Cancel()
    self.priceWarningTimeout = nil
  end
end

function AuctionatorBuyDialogMixin:UpdatePurchasedCount(newCount)
  self.NumberPurchased:SetShown(newCount ~= 0 and not self.priceWarningTimeout)
  self.NumberPurchased:SetText(AUCTIONATOR_L_ALREADY_PURCHASED_X:format(newCount))
end

function AuctionatorBuyDialogMixin:SetDetails(auctionData, initialQuantityPurchased)
  self:Reset()

  self.auctionData = auctionData
  self:Show()

  if self.auctionData == nil then
    self:Hide()
    return
  end

  self.quantityPurchased = initialQuantityPurchased or 0

  local stackText = BLUE_FONT_COLOR:WrapTextInColorCode("x" .. auctionData.stackSize)
  local priceText = Auctionator.Utilities.CreateMoneyString(auctionData.stackPrice)
  local unitPriceText = Auctionator.Utilities.CreateMoneyString(math.ceil(auctionData.stackPrice / auctionData.stackSize))
  self.PurchaseDetails:SetText(AUCTIONATOR_L_BUYING_X_FOR_X:format(stackText, priceText))
  self.UnitPrice:SetText(AUCTIONATOR_L_BRACKETS_X_EACH:format(unitPriceText))

  self:UpdatePurchasedCount(self.quantityPurchased)
  self:UpdateButtons()

  self:LoadForPurchasing()
end

function AuctionatorBuyDialogMixin:LoadForPurchasing()
  if self.auctionData.numStacks < 1 then
    self:UpdateButtons()
    if Auctionator.Config.Get(Auctionator.Config.Options.CHAIN_BUY_STACKS) and self.auctionData.nextEntry ~= nil then
      local nextEntry = self.auctionData.nextEntry

      -- Show warning if the price increases a lot
      local oldUnitPrice = self.auctionData.stackPrice / self.auctionData.stackSize
      local newUnitPrice = nextEntry.stackPrice / nextEntry.stackSize
      local priceIncrease = math.floor((newUnitPrice - oldUnitPrice) / oldUnitPrice * 100)
      if priceIncrease > Auctionator.Constants.PriceIncreaseWarningThreshold then
        -- Replace amount purchased text with warning text
        self.PriceWarning:Show()
        self.NumberPurchased:Hide()
        self.PriceWarning:SetText(AUCTIONATOR_L_PRICE_INCREASE_WARNING:format(priceIncrease .. "%", Auctionator.Constants.PriceIncreaseWarningDuration))
        self.priceWarningTimeout = C_Timer.NewTimer(Auctionator.Constants.PriceIncreaseWarningDuration, function()
          self.priceWarningTimeout = nil
          self.PriceWarning:Hide()
          -- Restore amount purchased text
          self:UpdatePurchasedCount(self.quantityPurchased)
          self:UpdateButtons()
        end)
      end

      self:SetDetails(self.auctionData.nextEntry, self.quantityPurchased)
    end
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
  self.BuyStack:SetEnabled(self.auctionData ~= nil and Auctionator.AH.IsNotThrottled() and self.buyInfo ~= nil and self.auctionData.numStacks > 0 and GetMoney() >= self.auctionData.stackPrice and not self.priceWarningTimeout)
  if self.auctionData and self.auctionData.numStacks > 0 then
    self.BuyStack:SetText(AUCTIONATOR_L_BUY_STACK)
  else
    self.BuyStack:SetText(AUCTIONATOR_L_NONE_LEFT)
  end
end

function AuctionatorBuyDialogMixin:SetChainBuy()
  Auctionator.Config.Set(Auctionator.Config.Options.CHAIN_BUY_STACKS, self.ChainBuy:GetChecked())
end

function AuctionatorBuyDialogMixin:BuyStackClicked()
  if self.auctionData.stackPrice > GetMoney() then
    self:UpdateButtons()
    return
  end

  self:SetChainBuy()
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
