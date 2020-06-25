local SALE_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnShow()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorSaleItemMixin")

  FrameUtil.RegisterFrameForEvents(self, SALE_ITEM_EVENTS)

  self:Reset()
end

function AuctionatorSaleItemMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
  })
  Auctionator.EventBus:UnregisterSource(self)

  FrameUtil.UnregisterFrameForEvents(self, SALE_ITEM_EVENTS)
end

function AuctionatorSaleItemMixin:OnUpdate()
  if self.itemInfo == nil then
    return
  end

  if self.Price:GetAmount() < 100 then
    self.Price:SetAmount(100)
  end

  self.TotalPrice:SetText(
    Auctionator.Utilities.CreateMoneyString(
      self.Quantity:GetNumber() * self.Price:GetAmount()
    )
  )

  if self.Quantity:GetNumber() > self.itemInfo.count then
    self.Quantity:SetNumber(self.itemInfo.count)
  elseif self.Quantity:GetNumber() < 1 then
    self.Quantity:SetNumber(1)
  end

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(self:GetDeposit()))
end

function AuctionatorSaleItemMixin:GetDeposit()
  local deposit = 0

  if self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
    deposit = C_AuctionHouse.CalculateCommodityDeposit(
      self.itemInfo.itemKey.itemID,
      self:GetDuration(),
      self.Quantity:GetNumber()
    )
  else
    deposit = C_AuctionHouse.CalculateItemDeposit(
      self.itemInfo.location,
      self:GetDuration(),
      self.Quantity:GetNumber()
    )
  end

  if deposit % 100 ~= 0 then
    deposit = deposit + (100 - (deposit % 100))
  end

  -- Need to have a price of at least one silver
  if deposit < 100 then
    deposit = 100
  end

  return deposit
end

function AuctionatorSaleItemMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self.itemInfo = ...
    self:Update()
  elseif event == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdatePostButtonState()
  elseif event == Auctionator.Selling.Events.RequestPost and
         self:GetPostButtonState() then
      self:PostItem()
  elseif event == Auctionator.Selling.Events.PriceSelected then
    local buyoutAmount, shouldUndercut = ...
    if shouldUndercut then
      if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
        buyoutAmount = Auctionator.Selling.CalculateNotLIFOPriceFromPrice(buyoutAmount)
      else --Not LIFO
        buyoutAmount = Auctionator.Selling.CalculateLIFOPriceFromPrice(buyoutAmount)
      end
    end
    self:UpdateSalesPrice(buyoutAmount)
  end
end

function AuctionatorSaleItemMixin:Update()
  self:UpdateDisplay()
  self:SetDefaults()
  self:UpdatePostButtonState()
end

function AuctionatorSaleItemMixin:UpdateDisplay()
  if self.itemInfo ~= nil then
    self.TitleArea.Text:SetText(
      self.itemInfo.name .. " - " ..
      Auctionator.Constants.ITEM_TYPE_STRINGS[self.itemInfo.itemType]
    )
    self.TitleArea.Text:SetTextColor(
      ITEM_QUALITY_COLORS[self.itemInfo.quality].r,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].g,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].b
    )

    self.Icon:HideCount()
    self.Icon:SetItemInfo(self.itemInfo)
    self.Quantity:SetNumber(self.itemInfo.count)

    local price = Auctionator.Database.GetPrice(
      Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = self.itemInfo.itemKey })
    )
    if price ~= nil then
      self:UpdateSalesPrice(price)
    end
  else
    self.TitleArea.Text:SetText("")
    self.Quantity:SetNumber(1)
    self:UpdateSalesPrice(0)
    self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(100))
    self.TotalPrice:SetText(Auctionator.Utilities.CreateMoneyString(100))
  end
end

function AuctionatorSaleItemMixin:SetDefaults()
  if self.itemInfo == nil then
    return
  end

  if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
    self:SetNotLifoDefaults()
  else
    self:SetLifoDefaults()
  end
end

function AuctionatorSaleItemMixin:Reset()
  self.itemInfo = nil
  self.Icon:SetItemInfo(nil)

  self:Update()
end

function AuctionatorSaleItemMixin:DoSearch(itemInfo, ...)
  if self.itemInfo.itemType ~= Auctionator.Constants.ITEM_TYPES.COMMODITY and
     itemInfo.itemKey.battlePetSpeciesID == 0 then
    Auctionator.AH.SendSellSearchQuery({itemID = itemInfo.itemKey.itemID}, ...)
  else
    Auctionator.AH.SendSearchQuery(itemInfo.itemKey, ...)
  end
  Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.SellSearchStart)
end

function AuctionatorSaleItemMixin:SetLifoDefaults()
  self.Duration:SetSelectedValue(
    Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
  )

  self:DoSearch(self.itemInfo, {sortOrder = 0, reverseSort = false}, true)
end

function AuctionatorSaleItemMixin:SetNotLifoDefaults()
  self.Duration:SetSelectedValue(
    Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION)
  )

  self:DoSearch(self.itemInfo, {sortOrder = 4, reverseSort = false}, true)
end

function AuctionatorSaleItemMixin:UpdateSalesPrice(salesPrice)
  local normalizedPrice = salesPrice

  -- Attempting to post an auction with copper value silently failes
  if normalizedPrice % 100 ~= 0 then
    normalizedPrice = normalizedPrice - (normalizedPrice % 100)
  end

  -- Need to have a price of at least one silver
  if normalizedPrice < 100 then
    normalizedPrice = 100
  end

  self.Price:SetAmount(normalizedPrice)
end

function AuctionatorSaleItemMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:ProcessCommodityResults(...)
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    self:ProcessItemResults(...)
  end
end

function AuctionatorSaleItemMixin:GetCommodityResult(itemId)
  if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId) > 0 then
    return C_AuctionHouse.GetCommoditySearchResultInfo(itemId, 1)
  else
    return nil
  end
end

function AuctionatorSaleItemMixin:ProcessCommodityResults(...)
  Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessCommodityResults()")

  local itemId = self.itemInfo.itemKey.itemID
  local itemKey = self.itemInfo.itemKey

  -- This event is called when in a few different situations where the entry may be nil, so check
  if itemId == nil or itemKey == nil then
    return
  end

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = itemKey })

  local result = self:GetCommodityResult(itemId)
  -- Update DB with current lowest price
  if result ~= nil then
    Auctionator.Database.SetPrice(dbKey, result.unitPrice)
  end

  -- A few cases to process here:
  -- 1. If the entry containsOwnerItem=true, I should use this price as my
  -- calculated posting price (i.e. I do not want to undercut myself)
  -- 2. Otherwise, this entry is what to base my calculation on:
  --    a. Undercut by percentage (player can choose 0% to become first item chosen via LIFO)
  --    b. Undercut by static value
  local postingPrice = nil

  if result == nil then
    -- This commodity was not found in the AH, so use the last lowest price from DB
    postingPrice = Auctionator.Database.GetPrice(dbKey)
  elseif result ~= nil and result.containsOwnerItem and result.owners[1] == "player" then
    -- No need to undercut myself
    postingPrice = result.unitPrice
  else
    -- Otherwise, we're not the lowest price, so calculate based on user preferences
    postingPrice = Auctionator.Selling.CalculateLIFOPriceFromPrice(result.unitPrice)
  end

  -- Didn't find anything currently posted, and nothing in DB
  if postingPrice == nil then
    Auctionator.Debug.Message("No prices have been recorded for this item.")
    return
  end

  self:UpdateSalesPrice(postingPrice)
end

local function copyKey(originalItemKey)
  return {
    itemLevel = originalItemKey.itemLevel,
    itemSuffix = originalItemKey.itemSuffix,
    itemID = originalItemKey.itemID,
    battlePetSpeciesID = originalItemKey.battlePetSpeciesID
  }
end

local function checkFullResults(itemKey)
  local entryCount = C_AuctionHouse.GetNumItemSearchResults(itemKey)
  local hasFullResults = C_AuctionHouse.RequestMoreItemSearchResults(itemKey)

  return entryCount, hasFullResults
end

function AuctionatorSaleItemMixin:GetItemResult(itemKey, itemCount, itemLevel)
  local currentResult

  for index = 1, itemCount do
    currentResult = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)

    if currentResult == nil then
      Auctionator.Debug.Message("Missing, break")
      break
    elseif currentResult.itemKey.itemLevel == itemLevel then
      -- Only get items at the same iLvl as the posted piece
      return currentResult
    end
  end

  return nil
end

function AuctionatorSaleItemMixin:ProcessItemResults(itemKey)
  Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()")
  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = itemKey })

  local entryCount, hasFullResults = checkFullResults(itemKey)

  if not hasFullResults then
    Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()", "Does not have full results or no items found.")
    return
  end

  local result = self:GetItemResult(itemKey, entryCount, self.itemInfo.itemKey.itemLevel)
  -- Update DB with current lowest price
  if result ~= nil then
    Auctionator.Database.SetPrice(dbKey, result.buyoutAmount)
  end

  local postingPrice = nil

  if result == nil then
    -- This item was not found in the AH, so use the lowest price from the dbKey
    -- TODO: DB price does not account for iLvl
    postingPrice = Auctionator.Database.GetPrice(dbKey)
  elseif result ~= nil and result.containsOwnerItem then
    -- Posting an item I have alread posted, and that is the current lowest price, so just
    -- use this price
    postingPrice = result.buyoutAmount
  else
    -- Otherwise, we're not the lowest price, so calculate based on user preferences
    if Auctionator.Utilities.IsNotLIFOItemKey(itemKey) then
      postingPrice = Auctionator.Selling.CalculateNotLIFOPriceFromPrice(result.buyoutAmount)
    else --Not LIFO
      postingPrice = Auctionator.Selling.CalculateLIFOPriceFromPrice(result.buyoutAmount)
    end
  end

  -- Didn't find anything currently posted, and nothing in DB
  if postingPrice == nil then
    Auctionator.Debug.Message("Lowest price not found.")
    return
  end

  self:UpdateSalesPrice(postingPrice)
end

function AuctionatorSaleItemMixin:GetPostButtonState()
  return self.itemInfo ~= nil and GetMoney() > self:GetDeposit() and Auctionator.AH.IsNotThrottled()
end

function AuctionatorSaleItemMixin:UpdatePostButtonState()
  if self:GetPostButtonState() then
    self.PostButton:Enable()
  else
    self.PostButton:Disable()
  end
end

local AUCTION_DURATIONS = {
  [12] = 1,
  [24] = 2,
  [48] = 3,
}

function AuctionatorSaleItemMixin:GetDuration()
  return AUCTION_DURATIONS[self.Duration:GetValue()]
end

function AuctionatorSaleItemMixin:PostItem()
  local quantity = self.Quantity:GetNumber()
  local duration = self:GetDuration()
  local buyout = self.Price:GetAmount()

  if self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
    C_AuctionHouse.PostItem(self.itemInfo.location, duration, quantity, nil, buyout)
  else
    C_AuctionHouse.PostCommodity(self.itemInfo.location, duration, quantity, buyout)
  end
  Auctionator.EventBus:Fire(self,
    Auctionator.Selling.Events.AuctionCreated,
    {
      itemLink = self.itemInfo.itemLink,
      quantity = quantity,
      buyoutAmount = buyout,
    }
  )

  self:Reset()
end
