AuctionatorItemSellingMixin = {}

local AUCTIONATOR_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_ADDED"
}

function AuctionatorItemSellingMixin:Initialize()
  Auctionator.Debug.Message("AuctionatorItemSellingMixin:Initialize()")

  hooksecurefunc(
    AuctionHouseFrame.ItemSellFrame.ItemDisplay,
    "SetItemInternal",
    function()
      self:SetDuration(
        AuctionHouseFrame.ItemSellFrame.DurationDropDown,
        Auctionator.Config.Get(Auctionator.Config.Options.ITEM_AUCTION_DURATION)
      )

      FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
    end
  )
end

function AuctionatorItemSellingMixin:AggregateItemResults(itemKey, itemCount, itemLevel)
  local results = {}
  local currentResult

  for index = 1, itemCount do
    currentResult = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)

    if currentResult == nil then
      break
    elseif currentResult.itemKey.itemLevel == itemLevel then
      -- Only aggregate items at the same iLvl as the posted piece
      table.insert(results, currentResult)
    end
  end

  return results
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
  local hasFullResults = entryCount > 0 and C_AuctionHouse.RequestMoreItemSearchResults(itemKey)

  return entryCount, hasFullResults
end

function AuctionatorItemSellingMixin:ProcessItemResults()
  Auctionator.Debug.Message("AuctionatorItemSellingMixin:ProcessItemResults()")

  -- This issues a GetItemKeyInfo which causes something to happen such that we get the full results...
  -- Blizzard_AuctionHouseUtil.lua#432
  -- originalItemKey has the actual ilvl of the posted item (ilvls may differ in returned results...)
  -- but gets overwritten when ConvertItemSellItemKey is called, so storing the itemLevel
  local originalItemKey = AuctionHouseFrame.ItemSellFrame.ItemDisplay:GetItemKey()

  -- This event is called when in a few different situations where the entry may be nil, so check
  if originalItemKey == nil then
    return
  end

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = originalItemKey })
  local originalCopy = copyKey(originalItemKey)
  local itemKey = AuctionHouseUtil.ConvertItemSellItemKey(originalItemKey)

  if itemKey == nil then
    Auctionator.Debug.Message("AuctionatorItemSellingMixin:ProcessItemResults()", "Item key was nil")
    return
  end

  local entryCount, hasFullResults = checkFullResults(itemKey)

  if not hasFullResults then
    Auctionator.Debug.Message("AuctionatorItemSellingMixin:ProcessItemResults()", "Does not have full results or no items found.")
    return
  end

  local results = self:AggregateItemResults(itemKey, entryCount, originalCopy.itemLevel)
  -- Update DB with current lowest price
  if #results > 0 then
    Auctionator.Database.SetPrice(dbKey, results[1].buyoutAmount)
  end

  local postingPrice = nil

  if #results == 0 then
    -- This item was not found in the AH, so use the lowest price from the dbKey
    -- TODO: DB price does not account for iLvl
    postingPrice = Auctionator.Database.GetPrice(dbKey)
  elseif #results > 0 and results[1].containsOwnerItem then
    -- Posting an item I have alread posted, and that is the current lowest price, so just
    -- use this price
    postingPrice = results[1].buyoutAmount
  else
    -- Otherwise, we're no the lowest price, so calculate based on user preferences
    postingPrice = self:CalculateItemPriceFromResults(results[1])
  end

  -- Didn't find anything currently posted, and nothing in DB
  if postingPrice == nil then
    Auctionator.Debug.Message("Lowest price not found, leaving default")
    return
  end

  self:UpdateSalesPrice(
    postingPrice,
    AuctionHouseFrame.ItemSellFrame.PriceInput
  )

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
end

local function userPrefersPercentage()
  return
    Auctionator.Config.Get(Auctionator.Config.Options.ITEM_AUCTION_SALES_PREFERENCE) ==
    Auctionator.Config.SalesTypes.PERCENTAGE
end

local function getPercentage()
  return (100 - Auctionator.Config.Get(Auctionator.Config.Options.ITEM_UNDERCUT_PERCENTAGE)) / 100
end

local function getSetAmount()
  return Auctionator.Config.Get(Auctionator.Config.Options.ITEM_UNDERCUT_STATIC_VALUE)
end

function AuctionatorItemSellingMixin:CalculateItemPriceFromResults(result)
  Auctionator.Debug.Message(" AuctionatorItemSellingMixin:CalculateItemPriceFromResults")
  local value

  if userPrefersPercentage() then
    value = result.buyoutAmount * getPercentage()

    Auctionator.Debug.Message("Percentage calculation", result.buyoutAmount, getPercentage(), value)
  else
    value = result.buyoutAmount - getSetAmount()

    Auctionator.Debug.Message("Static value calculation", result.buyoutAmount, getSetAmount(), value)
  end

  return value
end