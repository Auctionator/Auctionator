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

local function IsValidItem(item)
  return item ~= nil and
    -- May be a favourite with no items available, ignore it.
    item.location ~= nil and
    -- Location may be invalid because of items being moved in the bag
    C_Item.DoesItemExist(item.location)
end


AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnLoad()
  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE) then
    self.BidPrice:Show()
  end
end

function AuctionatorSaleItemMixin:OnShow()
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
    Auctionator.Selling.Events.RefreshSearch,
    Auctionator.Components.Events.EnterPressed,
  })
  Auctionator.EventBus:RegisterSource(self, "AuctionatorSaleItemMixin")

  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_POST_SHORTCUT), "CLICK AuctionatorPostButton:LeftButton")
  SetOverrideBinding(self, false, Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SKIP_SHORTCUT), "CLICK AuctionatorSkipPostingButton:LeftButton")

  self.lastItemInfo = nil
  self:UpdateSkipButton()
  self:Reset()
end

function AuctionatorSaleItemMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Selling.Events.RequestPost,
    Auctionator.AH.Events.ThrottleUpdate,
    Auctionator.Selling.Events.PriceSelected,
    Auctionator.Selling.Events.RefreshSearch,
    Auctionator.Components.Events.EnterPressed,
  })
  Auctionator.EventBus:UnregisterSource(self)
  self:UnlockItem()
  ClearOverrideBindings(self)
end

function AuctionatorSaleItemMixin:UpdateSkipButton()
  if Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) then
    self.PostButton:SetSize(114, 22)
    self.SkipButton:Show()
  else
    self.PostButton:SetSize(194, 22)
    self.SkipButton:Hide()
  end
end

function AuctionatorSaleItemMixin:UnlockItem()
  if self.itemInfo ~= nil then
    --Existence check added because of a bug report from a user where (for an
    --unknown reason) the item no longer existed.
    if self.itemInfo.count > 0 and C_Item.DoesItemExist(self.itemInfo.location) then
      C_Item.UnlockItem(self.itemInfo.location)
    end
    self.itemInfo = nil
  end
end

function AuctionatorSaleItemMixin:LockItem()
  if self.itemInfo.count > 0 then
    C_Item.LockItem(self.itemInfo.location)
  end
end

function AuctionatorSaleItemMixin:OnUpdate()
  if self.itemInfo == nil then
    return

  elseif self.itemInfo.count == 0 then
    return

  elseif not C_Item.DoesItemExist(self.itemInfo.location) then
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

  if self.Quantity:GetNumber() > self:GetPostLimit() then
    self:SetMax()
  end

  self.MaxButton:SetEnabled(self.Quantity:GetNumber() ~= self:GetPostLimit())

  self.DepositPrice:SetText(Auctionator.Utilities.CreateMoneyString(self:GetDeposit()))
  self:UpdatePostButtonState()
  self:UpdateSkipButtonState()
end

function AuctionatorSaleItemMixin:GetPostLimit()
  return math.min(C_AuctionHouse.GetAvailablePostCount(self.itemInfo.location), self.itemInfo.count)
end
function AuctionatorSaleItemMixin:SetMax()
  self.Quantity:SetNumber(self:GetPostLimit())
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

  elseif event == Auctionator.Components.Events.EnterPressed then
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

      self.itemInfo.keyName = AuctionHouseUtil.GetItemDisplayTextFromItemKey(
        itemKey, itemInfo, false
      )
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
  self:UpdateSkipButtonState()

end

function AuctionatorSaleItemMixin:UpdateVisuals()
  self.Icon:SetItemInfo(self.itemInfo)

  if self.itemInfo ~= nil then

    self.TitleArea.Text:SetText(self:GetItemName())

    self.Icon:HideCount()

    -- Fade the (optionally visible) bid price if posting a commodity
    if self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.COMMODITY then
      self.BidPrice:SetAlpha(0.5)
    else
      self.BidPrice:SetAlpha(1)
    end

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

  local price = Auctionator.Database:GetFirstPrice(
    Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = self.itemInfo.itemKey })
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
  local defaultQuantity = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_QUANTITIES)[self.itemInfo.classId]

  if self.itemInfo.count == 0 then
    self.Quantity:SetNumber(0)
  elseif defaultQuantity ~= nil and defaultQuantity > 0 then
    -- If a default quantity has been selected (ie non-zero amount)
    self.Quantity:SetNumber(math.min(self.itemInfo.count, defaultQuantity, self:GetPostLimit()))
  else
    -- No default quantity setting, use the maximum possible
    self:SetMax()
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

  if IsEquipment(itemInfo) and not Auctionator.Config.Get(Auctionator.Config.Options.SELLING_GEAR_USE_ILVL) then
    -- Bug with PTR C_AuctionHouse.MakeItemKey(...), it always sets the
    -- itemLevel to a non-zero value, so we have to create the key directly
    self.expectedItemKey = {itemID = itemInfo.itemKey.itemID, itemLevel = 0, itemSuffix = 0, battlePetSpeciesID = 0}
    Auctionator.AH.SendSellSearchQuery(self.expectedItemKey, {sortingOrder}, true)
  else
    self.expectedItemKey = itemInfo.itemKey
    Auctionator.AH.SendSearchQuery(itemInfo.itemKey, {sortingOrder}, true)
  end
  Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.SellSearchStart, self.expectedItemKey)
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
  self.BidPrice:Clear()
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

  local dbKeys = Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = C_AuctionHouse.MakeItemKey(itemID) })

  local result = self:GetCommodityResult(itemID)
  -- Update DB with current lowest price
  if result ~= nil then
    for _, key in ipairs(dbKeys) do
      Auctionator.Database:SetPrice(key, result.unitPrice)
    end
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
    postingPrice = Auctionator.Database:GetFirstPrice(dbKeys)
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

  local dbKeys = Auctionator.Utilities.DBKeyFromBrowseResult({ itemKey = itemKey })

  local result = self:GetItemResult(itemKey)

  -- Update DB with current lowest price
  if result ~= nil then
    for _, key in ipairs(dbKeys) do
      Auctionator.Database:SetPrice(key, result.buyoutAmount or result.bidAmount)
    end
  end

  local postingPrice = nil

  if result == nil then
    -- This item was not found in the AH, so use the lowest price from the dbKey
    -- TODO: DB price does not account for iLvl
    postingPrice = Auctionator.Database:GetFirstPrice(dbKeys)
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
    self.itemInfo.count > 0 and

    C_Item.DoesItemExist(self.itemInfo.location) and

    -- Sufficient money to cover deposit
    GetMoney() > self:GetDeposit() and

    -- Valid quantity
    self.Quantity:GetNumber() > 0 and
    self.Quantity:GetNumber() <= self:GetPostLimit() and

    -- Positive price
    self.Price:GetAmount() > 0 and

    -- Bid price is not bigger than buyout
    self.BidPrice:GetAmount() <= self.Price:GetAmount() and

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

function AuctionatorSaleItemMixin:UpdateSkipButtonState()
  self.SkipButton:SetEnabled(self.SkipButton:IsShown() and IsValidItem(self.itemInfo and self.itemInfo.nextItem))
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
  local startingBid = self.BidPrice:GetAmount()
  local buyout = self.Price:GetAmount()
  local bidAmountReported = nil -- Only includes bid price when non-zero and for an item

  self.MultisellProgress:SetDetails(self.itemInfo.iconTexture, quantity)

  if self.itemInfo.itemType == Auctionator.Constants.ITEM_TYPES.ITEM then
    if startingBid ~= 0 then
      bidAmountReported = startingBid
      C_AuctionHouse.PostItem(self.itemInfo.location, duration, quantity, startingBid, buyout)
    else
      C_AuctionHouse.PostItem(self.itemInfo.location, duration, quantity, nil, buyout)
    end
  else
    C_AuctionHouse.PostCommodity(self.itemInfo.location, duration, quantity, buyout)
  end

  Auctionator.EventBus:Fire(self,
    Auctionator.Selling.Events.AuctionCreated,
    {
      itemLink = self.itemInfo.itemLink,
      quantity = quantity,
      buyoutAmount = buyout,
      bidAmount = bidAmountReported,
    }
  )

  Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.RefreshHistory)

  -- Save item info for refreshing search results
  self.lastItemInfo = self.itemInfo
  self:Reset()

  if (Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT) and
      IsValidItem(self.lastItemInfo.nextItem)
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

function AuctionatorSaleItemMixin:SkipItem()
  if self.SkipButton:IsEnabled() then
    Auctionator.EventBus:Fire(
      self, Auctionator.Selling.Events.BagItemClicked, self.itemInfo.nextItem
    )
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
