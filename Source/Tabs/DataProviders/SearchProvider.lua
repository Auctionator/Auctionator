local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantity" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_ITEM_LEVEL_COLUMN,
    headerParameters = { "level" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "level" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "owned" },
    headerText = AUCTIONATOR_L_OWNED_COLUMN,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "owned" },
    width = 70
  },
}

local SEARCH_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "ITEM_SEARCH_RESULTS_UPDATED",

  --Used to update the search when a cancel happens
  "AUCTION_CANCELED",
}

SearchProviderMixin = CreateFromMixins(DataProviderMixin)

function SearchProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.SellSearchStart
  })

  self:Reset()
end

function SearchProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.SellSearchStart
  })
end

function SearchProviderMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.Selling.Events.SellSearchStart then
    self:Reset()
    self.onSearchStarted()
  end
end

function SearchProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  available = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
  owned = Auctionator.Utilities.StringComparator,
}

function SearchProviderMixin:UniqueKey(entry)
  return entry.auctionID
end

function SearchProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function SearchProviderMixin:OnEvent(eventName, ...)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:Reset()
    self:AppendEntries(self:ProcessCommodityResults(...))

  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    self:Reset()
    self:AppendEntries(self:ProcessItemResults(...))

  elseif eventName == "AUCTION_CANCELED" then
    Auctionator.EventBus
      :RegisterSource(self, "SearchProviderMixin")
      :Fire(self, Auctionator.Selling.Events.RefreshSearch)
      :UnregisterSource(self)
  end
end

function SearchProviderMixin:ProcessCommodityResults(itemID)
  local entries = {}
  local anyOwnedCannotCancel = false

  for index = C_AuctionHouse.GetNumCommoditySearchResults(itemID), 1, -1 do
    local resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
    local entry = {
      price = resultInfo.unitPrice,
      owners = resultInfo.owners,
      quantity = resultInfo.quantity,
      level = "0",
      auctionID = resultInfo.auctionID,
      itemID = itemID,
      itemType = Auctionator.Constants.ITEM_TYPES.COMMODITY,
    }
    if resultInfo.containsOwnerItem then
      if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
        anyOwnedCannotCancel = true
      end
      entry.owned = AUCTIONATOR_L_UNDERCUT_YES
    else
      entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end

    table.insert(entries, entry)
  end

  if anyOwnedCannotCancel and Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CLICK_CANCEL) then
    C_AuctionHouse.QueryOwnedAuctions({})
  end

  return entries, C_AuctionHouse.RequestMoreCommoditySearchResults(itemID)
end

function SearchProviderMixin:ProcessItemResults(itemKey)
  local entries = {}
  local anyOwnedCannotCancel = false

  for index = C_AuctionHouse.GetNumItemSearchResults(itemKey), 1, -1 do
    local resultInfo = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    local entry = {
      price = resultInfo.buyoutAmount or resultInfo.bidAmount,
      level = tostring(resultInfo.itemKey.itemLevel or 0),
      owners = resultInfo.owners,
      quantity = resultInfo.quantity,
      itemLink = resultInfo.itemLink,
      auctionID = resultInfo.auctionID,
      itemType = Auctionator.Constants.ITEM_TYPES.ITEM,
    }
    if resultInfo.containsOwnerItem then
      if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
        anyOwnedCannotCancel = true
      end
      entry.owned = AUCTIONATOR_L_UNDERCUT_YES
    else
      entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end

    table.insert(entries, entry)
  end

  if anyOwnedCannotCancel and Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CLICK_CANCEL) then
    Auctionator.AH.QueryOwnedAuctions({})
  end

  return entries, C_AuctionHouse.RequestMoreItemSearchResults(itemKey)
end

function SearchProviderMixin:GetRowTemplate()
  return "AuctionatorSellSearchRowTemplate"
end
