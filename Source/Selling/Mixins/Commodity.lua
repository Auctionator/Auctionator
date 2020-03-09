AuctionatorCommoditySellingMixin = {}

local AUCTIONATOR_COMMODITY_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "COMMODITY_SEARCH_RESULTS_ADDED"
}

function AuctionatorCommoditySellingMixin:Initialize()
  Auctionator.Debug.Message("AuctionatorCommoditySellingMixin:Initialize()")

  hooksecurefunc(
    AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay,
    "SetItemInternal",
    function()
      self:SetDuration(
        AuctionHouseFrame.CommoditiesSellFrame.DurationDropDown,
        Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_AUCTION_DURATION)
      )

      FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
    end
  )
end

function AuctionatorCommoditySellingMixin:AggregateCommodityResults(itemId)
  local results = {}
  local currentResult

  for index = 1, C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId) do
    currentResult = C_AuctionHouse.GetCommoditySearchResultInfo(itemId, index)

    if currentResult == nil then
      break
    end

    table.insert(results, currentResult)
  end

  return results
end

function AuctionatorCommoditySellingMixin:ProcessCommodityResults()
  Auctionator.Debug.Message("AuctionatorCommoditySellingMixin:ProcessCommodityResults()")

  local itemId = AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay:GetItemID()
  local itemKey = AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay:GetItemKey()

  -- This event is called when in a few different situations where the entry may be nil, so check
  if itemId == nil or itemKey == nil then
    return
  end

  local dbKey = Auctionator.Utilities.ItemKeyFromBrowseResult({ itemKey = itemKey })

  local results = self:AggregateCommodityResults(itemId)
  -- Update DB with current lowest price
  if #results > 0 then
    Auctionator.Database.SetPrice(dbKey, results[1].unitPrice)
  end

  -- A few cases to process here:
  -- 1. If entry at results[1] has containsOwnerItem=true, I should
  --    use this price as my calculated posting price (i.e. I do not want to undercut myself)
  -- 2. Otherwise, entry at results[1] is what to base my calculation on:
  --    a. Undercut by percentage (player can choose 0% to become first item chosen via LIFO)
  --    b. Undercut by static value
  local postingPrice = nil

  if #results == 0 then
    -- This commodity was not found in the AH, so use the last lowest price from DB
    postingPrice = Auctionator.Database.GetPrice(dbKey)
  elseif #results > 0 and results[1].containsOwnerItem then
    -- No need to undercut myself (although the user probably wants to re-post existing auctions
    -- at the same price if they are not first)
    postingPrice = results[1].unitPrice

    if results[1].owners[1] ~= "player" then
      Auctionator.Utilities.Message(
        RED_FONT_COLOR:WrapTextInColorCode("You have auctions for this commodity that are not the most recent.")
      )
    end
  else
    -- Otherwise, we're not the lowest price, so calculate based on user preferences
    postingPrice = self:CalculateCommodityPriceFromResults(results[1])
  end

  -- Didn't find anything currently posted, and nothing in DB
  if postingPrice == nil then
    Auctionator.Debug.Message("Lowest price not found, leaving default")
    return
  end

  self:UpdateSalesPrice(
    postingPrice,
    AuctionHouseFrame.CommoditiesSellFrame.PriceInput
  )

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
end

local function userPrefersPercentage()
  return
    Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_AUCTION_SALES_PREFERENCE) ==
    Auctionator.Config.SalesTypes.PERCENTAGE
end

local function getPercentage()
  return (100 - Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_UNDERCUT_PERCENTAGE)) / 100
end

local function getSetAmount()
  return Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_UNDERCUT_STATIC_VALUE)
end

function AuctionatorCommoditySellingMixin:CalculateCommodityPriceFromResults(result)
  Auctionator.Debug.Message(" AuctionatorCommoditySellingMixin:CalculateCommodityPriceFromResults")
  local value

  if userPrefersPercentage() then
    value = result.unitPrice * getPercentage()

    Auctionator.Debug.Message("Percentage calculation", result.unitPrice, getPercentage(), value)
  else
    value = result.unitPrice - getSetAmount()

    Auctionator.Debug.Message("Static value calculation", result.unitPrice, getSetAmount(), value)
  end

  return value
end