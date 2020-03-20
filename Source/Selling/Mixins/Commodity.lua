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
        Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
      )

      FrameUtil.RegisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
    end
  )
  -- Used to grey out the post button when throttling takes place
  hooksecurefunc(AuctionHouseFrame.CommoditiesSellFrame,
    "UpdatePostButtonState",
    function()
      self:UpdateCommoditySellButton()
    end
  )
end

function AuctionatorCommoditySellingMixin:UpdateCommoditySellButton()
  if self.throttled or
     AuctionHouseFrame.CommoditiesSellFrame:CanPostItem() then
    Auctionator.Utilities.ApplyThrottlingButton(
      AuctionHouseFrame.CommoditiesSellFrame.PostButton,
      self.throttled
    )
  end
end

function AuctionatorCommoditySellingMixin:GetCommodityResult(itemId)
  if C_AuctionHouse.GetCommoditySearchResultsQuantity(itemId) > 0 then
    return C_AuctionHouse.GetCommoditySearchResultInfo(itemId, 1)
  else
    return nil
  end
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
    Auctionator.Debug.Message("Lowest price not found, leaving default")
    return
  end

  self:UpdateSalesPrice(
    postingPrice,
    AuctionHouseFrame.CommoditiesSellFrame.PriceInput
  )

  FrameUtil.UnregisterFrameForEvents(self, AUCTIONATOR_COMMODITY_EVENTS)
end
