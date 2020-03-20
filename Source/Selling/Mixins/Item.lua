AuctionatorItemSellingMixin = {}

local AUCTIONATOR_ITEM_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_ADDED"
}

local function GetItemDuration(itemLocation)
  if itemLocation == nil then
    return Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
  end

  local itemKey = C_AuctionHouse.GetItemKeyFromItem(itemLocation)
  if Auctionator.Utilities.IsNotLIFOItemKey(itemKey) then
    Auctionator.Debug.Message("Not LIFO itemKey")
    return Auctionator.Config.Get(Auctionator.Config.Options.NOT_LIFO_AUCTION_DURATION)
  else
    Auctionator.Debug.Message("LIFO itemKey")
    return Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
  end
end

function AuctionatorItemSellingMixin:Initialize()
  Auctionator.Debug.Message("AuctionatorItemSellingMixin:Initialize()")

  hooksecurefunc(
    AuctionHouseFrame.ItemSellFrame.ItemDisplay,
    "SetItemInternal",
    function()
      self:SetDuration(
        AuctionHouseFrame.ItemSellFrame.DurationDropDown,
        GetItemDuration(
          AuctionHouseFrame.ItemSellFrame.ItemDisplay:GetItemLocation()
        )
      )

      FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
    end
  )
  -- Used to grey out the post button when throttling takes place
  hooksecurefunc(AuctionHouseFrame.ItemSellFrame,
    "UpdatePostButtonState",
    function()
      self:UpdateItemSellButton()
    end
  )
end

function AuctionatorItemSellingMixin:UpdateItemSellButton()
  if self.throttled or
     AuctionHouseFrame.ItemSellFrame:CanPostItem() then
    Auctionator.Utilities.ApplyThrottlingButton(
      AuctionHouseFrame.ItemSellFrame.PostButton,
      self.throttled
    )
  end
end

function AuctionatorItemSellingMixin:GetItemResult(itemKey, itemCount, itemLevel)
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
    Auctionator.Debug.Message("Lowest price not found, leaving default")
    return
  end

  self:UpdateSalesPrice(
    postingPrice,
    AuctionHouseFrame.ItemSellFrame.PriceInput
  )

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_ITEM_EVENTS)
end
