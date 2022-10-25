AuctionatorBuyDialogMixin = {}

local QUERY_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

local EVENTS = {
  Auctionator.AH.Events.ThrottleUpdate,
}

local MONEY_EVENTS = {
  "PLAYER_MONEY",
  "UI_ERROR_MESSAGE",
  "CHAT_MSG_SYSTEM",
}

function AuctionatorBuyDialogMixin:OnLoad()
  self:RegisterForDrag("LeftButton")
  self.NumberPurchased:SetText(AUCTIONATOR_L_ALREADY_PURCHASED_X:format(15))
  self.PurchaseDetails:SetText(AUCTIONATOR_L_BUYING_X_FOR_X:format(BLUE_FONT_COLOR:WrapTextInColorCode("x20"), GetMoneyString(10998, true)))
  self.UnitPrice:SetText(AUCTIONATOR_L_BRACKETS_X_EACH:format(GetMoneyString(550, true)))
  Auctionator.EventBus:RegisterSource(self, "BuyDialogMixin")

  self:Reset()
end

function AuctionatorBuyDialogMixin:Reset()
  self.auctionData = nil
  self.buyInfo = nil
  self.blacklistedBefore = 0
  self.gotAllResults = true
  self.quantityPurchased = 0
  self.lastBuyStackSize = 0
end

function AuctionatorBuyDialogMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_MONEY" then
    self:UpdateButtons()
  elseif eventName == "UI_ERROR_MESSAGE" then
    local _, message = ...
    if message == ERR_ITEM_NOT_FOUND and self.buyInfo ~= nil then
      Auctionator.Debug.Message("AuctionatorBuyDialogMixin", "failed purchase", self.buyInfo.index, self.lastBuyStackSize)
      self.lastBuyStackSize = 0
      self.blacklistedBefore = self.buyInfo.index
      self:SetDetails(self.auctionData, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
      self:LoadForPurchasing()
    end
  elseif eventName == "CHAT_MSG_SYSTEM" then
    local message = ...
    if message == ERR_AUCTION_BID_PLACED then
      self.quantityPurchased = self.quantityPurchased + self.lastBuyStackSize
      self:SetDetails(self.auctionData, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
      self:LoadForPurchasing()
    end
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

function AuctionatorBuyDialogMixin:SetDetails(auctionData, initialQuantityPurchased, lastBuyStackSize, blacklistedBefore)
  self:Reset()

  self.auctionData = auctionData
  self:Show()

  if self.auctionData == nil then
    self:Hide()
    return
  end

  self.quantityPurchased = initialQuantityPurchased or 0
  self.lastBuyStackSize = lastBuyStackSize or 0
  self.blacklistedBefore = blacklistedBefore or 0

  local stackText = BLUE_FONT_COLOR:WrapTextInColorCode("x" .. auctionData.stackSize)
  local priceText = GetMoneyString(auctionData.stackPrice, true)
  local unitPriceText = GetMoneyString(math.ceil(auctionData.stackPrice / auctionData.stackSize), true)
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

      self:SetDetails(self.auctionData.nextEntry, self.quantityPurchased, self.lastBuyStackSize, self.blacklistedBefore)
    end
    return
  end

  Auctionator.AH.AbortQuery()
  self:FindAuctionOnCurrentPage()
  if self.buyInfo == nil then
    self.blacklistedBefore = 0
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
        self:GetParent():DoRefresh()
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
    if index > self.blacklistedBefore then
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
    self.lastBuyStackSize = self.auctionData.stackSize
    self:UpdatePurchasedCount(self.quantityPurchased)
    Auctionator.EventBus:Fire(self, Auctionator.Buying.Events.StacksUpdated)
  end
  self:LoadForPurchasing()
end
