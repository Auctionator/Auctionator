local AUCTIONATOR_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED"
}

local AUCTIONATOR_COMMODITY_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED"
}

AuctionatorSaleItemMixin = {}

function AuctionatorSaleItemMixin:OnLoad()
  Auctionator.EventBus:Register( self, { Auctionator.Selling.Events.BagItemClicked })
end

function AuctionatorSaleItemMixin:ReceiveEvent(event, itemInfo)
  if event == Auctionator.Selling.Events.BagItemClicked then
    self.itemInfo = itemInfo
    self:UpdateDisplay()
    self:SetDefaults()
  end
end

function AuctionatorSaleItemMixin:UpdateDisplay()
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
end

function AuctionatorSaleItemMixin:SetDefaults()
  if Auctionator.Utilities.IsNotLIFOItemKey(self.itemInfo.itemKey) then
    self:SetNotLifoDefaults()
  else
    self:SetLifoDefaults()
  end
end

function AuctionatorSaleItemMixin:SetLifoDefaults()
  self.Duration:SetSelectedValue(
    Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
  )

  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
  Auctionator.AH.SendSearchQuery(self.itemInfo.itemKey, {sortOrder = 0, reverseSort = false}, true)
end

function AuctionatorSaleItemMixin:SetNotLifoDefaults()
  self.Duration:SetSelectedValue(
    Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION)
  )

  FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
  Auctionator.AH.SendSearchQuery(self.itemInfo.itemKey, {sortOrder = 4, reverseSort = false}, true)
end

function AuctionatorSaleItemMixin:UpdateSalesPrice(salesPrice)
  print("update", salesPrice)
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

  -- C_AuctionHouse.CalculateCommodityDeposit(C_Item.GetItemID(item), duration, quantity)

  self:UpdateSalesPrice(postingPrice)

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
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

function AuctionatorSaleItemMixin:ProcessItemResults(...)
  Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()")

  -- This issues a GetItemKeyInfo which causes something to happen such that we get the full results...
  -- Blizzard_AuctionHouseUtil.lua#432
  -- originalItemKey has the actual ilvl of the posted item (ilvls may differ in returned results...)
  -- but gets overwritten when ConvertItemSellItemKey is called, so storing the itemLevel
  local originalItemKey = self.itemInfo.itemKey

  -- This event is called when in a few different situations where the entry may be nil, so check
  if originalItemKey == nil then
    return
  end

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = originalItemKey })
  local originalCopy = copyKey(originalItemKey)
  local itemKey = AuctionHouseUtil.ConvertItemSellItemKey(originalItemKey)

  if itemKey == nil then
    Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()", "Item key was nil")
    return
  end

  local entryCount, hasFullResults = checkFullResults(itemKey)

  if not hasFullResults then
    Auctionator.Debug.Message("AuctionatorSaleItemMixin:ProcessItemResults()", "Does not have full results or no items found.")
    return
  end

  local result = self:GetItemResult(itemKey, entryCount, originalCopy.itemLevel)
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

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
end
