local SALE_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_UPDATED",
}

-- Necessary because attempting to post an auction with copper value silently
-- failes
local function NormalizePrice(price)
  local normalizedPrice = price

  -- Round up
  if normalizedPrice % 100 ~= 0 then
    normalizedPrice = normalizedPrice + (100 - normalizedPrice % 100)
  end

  -- Need to have a price of at least one silver
  if normalizedPrice < 100 then
    normalizedPrice = 100
  end

  return normalizedPrice
end

local function IsEquipment(itemInfo)
  return itemInfo.classId == LE_ITEM_CLASS_WEAPON or itemInfo.classId == LE_ITEM_CLASS_ARMOR
end

AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnShow()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
    Auctionator.Selling.Events.RefreshSearch,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorSaleItemMixin")

  self.lastItemInfo = nil
  self:Reset()
end

function AuctionatorSaleItemMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
    Auctionator.Selling.Events.RefreshSearch,
  })
  Auctionator.EventBus:UnregisterSource(self)
  self:UnlockItem()
end

function AuctionatorSaleItemMixin:UnlockItem()
  if self.itemInfo ~= nil then
    C_Item.UnlockItem(self.itemInfo.location)
    self.itemInfo = nil
  end
end

function AuctionatorSaleItemMixin:LockItem()
  C_Item.LockItem(self.itemInfo.location)
end

function AuctionatorSaleItemMixin:OnUpdate()
  if self.itemInfo == nil then
    return
  end

  if not C_Item.DoesItemExist(self.itemInfo.location) then
    --Bag item location invalid due to posting (race condition)
    self.itemInfo = nil
    self:Reset()
    return
  end

  self.TotalPrice:SetText(
    Auctionator.Utilities.CreateMoneyString(
      self.Quantity:GetNumber() * self.Price:GetAmount()
    )
  )

  if self.Quantity:GetNumber() > self.itemInfo.count then
    self:SetMax()
  end

  self.MaxButton:SetEnabled(self.Quantity:GetNumber() ~= self.itemInfo.count)

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(self:GetDeposit()))
  self:UpdatePostButtonState()
end

function AuctionatorSaleItemMixin:SetMax()
  self.Quantity:SetNumber(self.itemInfo.count)
end

function AuctionatorSaleItemMixin:GetDeposit()
  local deposit = 0

  if self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
    deposit = C_AuctionHouse.CalculateCommodityDeposit(
      self.itemInfo.itemKey.itemID,
      self:GetDuration(),
      self.Quantity:GetNumber()
    )

  elseif self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
    deposit = C_AuctionHouse.CalculateItemDeposit(
      self.itemInfo.location,
      self:GetDuration(),
      self.Quantity:GetNumber()
    )
  end

  return NormalizePrice(deposit)
end

function AuctionatorSaleItemMixin:ReceiveEvent(event, ...)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self:UnlockItem()
    self.itemInfo = ...
    self:LockItem()
    self:Update()

  elseif event == Auctionator.AH.Events.ThrottleUpdate then
    self:UpdatePostButtonState()

  elseif event == Auctionator.Selling.Events.RequestPost then
    self:PostItem()

  elseif event == Auctionator.Selling.Events.PriceSelected and
         self.itemInfo ~= nil then
    local buyoutAmount, shouldUndercut = ...

    if shouldUndercut then
      if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
        buyoutAmount = Auctionator.Selling.CalculateNotLIFOPriceFromPrice(buyoutAmount)
      else --Not LIFO
        buyoutAmount = Auctionator.Selling.CalculateLIFOPriceFromPrice(buyoutAmount)
      end
    end

    self:UpdateSalesPrice(buyoutAmount)

  elseif event == Auctionator.AH.Events.ItemKeyInfo then
    local itemKey, itemInfo = ...
    if Auctionator.Utilities.ItemKeyString(self.itemInfo.itemKey) ==
        Auctionator.Utilities.ItemKeyString(itemKey) then
      Auctionator.EventBus:Unregister(self, {Auctionator.AH.Events.ItemKeyInfo})

      self.itemInfo.keyName = itemInfo.itemName
      self:UpdateVisuals()
    end

  elseif event == Auctionator.Selling.Events.RefreshSearch then
    self:RefreshButtonClicked()
  end
end

function AuctionatorSaleItemMixin:Update()
  self:UpdateVisuals()

  if self.itemInfo ~= nil then
    self:UpdateForNewItem()
  else
    self:UpdateForNoItem()
  end

  self:UpdatePostButtonState()

end

function AuctionatorSaleItemMixin:UpdateVisuals()
  self.Icon:SetItemInfo(self.itemInfo)

  if self.itemInfo ~= nil then

    self.TitleArea.Text:SetText(self:GetItemName())

    self.TitleArea.Text:SetTextColor(
      ITEM_QUALITY_COLORS[self.itemInfo.quality].r,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].g,
      ITEM_QUALITY_COLORS[self.itemInfo.quality].b
    )

    self.Icon:HideCount()

  else
    -- No item, reset all the visuals
    self.TitleArea.Text:SetText("")
  end
end

-- The exact item name is only loaded when needed as it slows down loading the
-- bag items too much to do in BagDataProvider.
function AuctionatorSaleItemMixin:GetItemName()
  if self.itemInfo.keyName ~= nil then
    return self.itemInfo.keyName

  else
    Auctionator.EventBus:Register(self, {Auctionator.AH.Events.ItemKeyInfo})
    Auctionator.AH.GetItemKeyInfo(self.itemInfo.itemKey)

    return ""
  end
end

function AuctionatorSaleItemMixin:UpdateForNewItem()
  self:SetDuration()

  self:SetQuantity()

  local price = Auctionator.Database.GetPrice(
    Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = self.itemInfo.itemKey })
  )
  if price ~= nil then
    self:UpdateSalesPrice(price)
  elseif IsEquipment(self.itemInfo) then
    self:SetEquipmentMultiplier(self.itemInfo.itemLink)
  else
    self:UpdateSalesPrice(0)
  end

  self:DoSearch(self.itemInfo)
end

function AuctionatorSaleItemMixin:UpdateForNoItem()
  self.Quantity:SetNumber(0)
  self.MaxButton:Disable()
  self:UpdateSalesPrice(0)

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(100))
  self.TotalPrice:SetText(Auctionator.Utilities.CreateMoneyString(100))
end

function AuctionatorSaleItemMixin:SetDuration()
  if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
    self.Duration:SetSelectedValue(
      Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION)
    )

  else
    self.Duration:SetSelectedValue(
      Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
    )
  end
end

function AuctionatorSaleItemMixin:SetQuantity()
  local defaultQuantity

  if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
    defaultQuantity = Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_DEFAULT_QUANTITY)
  else
    defaultQuantity = Auctionator.Config.Get(Auctionator.Config.Options.LIFO_DEFAULT_QUANTITY)
  end

  if defaultQuantity > 0 then
    -- If a default quantity has been selected (ie non-zero amount)
    self.Quantity:SetNumber(math.min(self.itemInfo.count, defaultQuantity))
  else
    -- No default quantity setting, use the maximum possible
    self.Quantity:SetNumber(self.itemInfo.count)
  end
end

function AuctionatorSaleItemMixin:DoSearch(itemInfo, ...)
  FrameUtil.RegisterFrameForEvents(self, SALE_ITEM_EVENTS)

  local sortingOrder

  if itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
    sortingOrder = {sortOrder = 0, reverseSort = false}
  else
    sortingOrder = {sortOrder = 4, reverseSort = false}
  end

  if IsEquipment(itemInfo) then
    -- Bug with PTR C_AuctionHouse.MakeItemKey(...), it always sets the
    -- itemLevel to a non-zero value, so we have to create the key directly
    self.expectedItemKey = {itemID = itemInfo.itemKey.itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
    Auctionator.AH.SendSellSearchQuery(self.expectedItemKey, {sortingOrder}, true)
  else
    self.expectedItemKey = itemInfo.itemKey
    Auctionator.AH.SendSearchQuery(itemInfo.itemKey, {sortingOrder}, true)
  end
  Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.SellSearchStart)
end

function AuctionatorSaleItemMixin:Reset()
  self:UnlockItem()

  self:Update()
end

function AuctionatorSaleItemMixin:UpdateSalesPrice(salesPrice)
  if salesPrice == 0 then
    self.Price:SetAmount(0)
  else
    self.Price:SetAmount(NormalizePrice(salesPrice))
  end
end

function AuctionatorSaleItemMixin:SetEquipmentMultiplier(itemLink)
  self:UpdateSalesPrice(0)

  local item = Item:CreateFromItemLink(itemLink)
  item:ContinueOnItemLoad(function()
    local multiplier = Auctionator.Config.Get(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER)
    local vendorPrice = select(11, GetItemInfo(itemLink))
    if multiplier ~= 0 and vendorPrice ~= 0 then
      -- Check for a vendor price multiplier being set (and a vendor price)
      self:UpdateSalesPrice(
        vendorPrice * multiplier + self:GetDeposit()
      )
    end
  end)
end

function AuctionatorSaleItemMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    local itemID = ...
    if itemID ~= self.expectedItemKey.itemID then
      return
    end

    self:ProcessCommodityResults(...)
    FrameUtil.UnregisterFrameForEvents(self, SALE_ITEM_EVENTS)

  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    local itemKey = ...
    if Auctionator.Utilities.ItemKeyString(itemKey) ~=
        Auctionator.Utilities.ItemKeyString(self.expectedItemKey) then
      return
    end

    self:ProcessItemResults(...)
    FrameUtil.UnregisterFrameForEvents(self, SALE_ITEM_EVENTS)
  end

end

function AuctionatorSaleItemMixin:GetCommodityResult(itemId)
  if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId) > 0 then
    return C_AuctionHouse.GetCommoditySearchResultInfo(itemId, 1)
  else
    return nil
  end
end

function AuctionatorSaleItemMixin:ProcessCommodityResults(itemID, ...)
  Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessCommodityResults()")

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = C_AuctionHouse.MakeItemKey(itemID) })

  local result = self:GetCommodityResult(itemID)
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

function AuctionatorSaleItemMixin:GetItemResult(itemKey)
  if C_AuctionHouse.GetItemSearchResultsQuantity(itemKey) > 0 then
    return C_AuctionHouse.GetItemSearchResultInfo(itemKey, 1)
  else
    return nil
  end
end

function AuctionatorSaleItemMixin:ProcessItemResults(itemKey)
  Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()")

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = itemKey })

  local result = self:GetItemResult(itemKey)

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
  return
    self.itemInfo ~= nil and

    C_Item.DoesItemExist(self.itemInfo.location) and

    -- Sufficient money to cover deposit
    GetMoney() > self:GetDeposit() and

    -- Valid quantity
    self.Quantity:GetNumber() > 0 and
    self.Quantity:GetNumber() <= self.itemInfo.count and

    -- Positive price
    self.Price:GetAmount() > 0 and

    -- Not throttled (to avoid silent post failure)
    Auctionator.AH.IsNotThrottled()
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
  if not self:GetPostButtonState() then
    Auctionator.Debug.Message("Trying to post when we can't. Returning")
    return
  end

  local quantity = self.Quantity:GetNumber()
  local duration = self:GetDuration()
  local buyout = self.Price:GetAmount()

  self.MultisellProgress:SetDetails(self.itemInfo.iconTexture, quantity)

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

  -- Save item info for refreshing search results
  self.lastItemInfo = self.itemInfo
  self:Reset()

  if (Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) and
      self.lastItemInfo.nextItem ~= nil and
      -- Location may be invalid because of items being moved in the bag
      C_Item.DoesItemExist(self.lastItemInfo.nextItem.location)
    ) then
    -- Option to automatically select the next item in the bag view
    Auctionator.EventBus:Fire(
      self, Auctionator.Selling.Events.BagItemClicked, self.lastItemInfo.nextItem
    )

  else
    -- Search for current auctions of the last item posted
    self:DoSearch(self.lastItemInfo)
  end
end

function AuctionatorSaleItemMixin:RefreshButtonClicked()
  -- Search for the current item or the last item posted
  if self.itemInfo ~= nil then
    self:DoSearch(self.itemInfo)
  elseif self.lastItemInfo ~= nil then
    self:DoSearch(self.lastItemInfo)
  end
end
