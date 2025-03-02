local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTIONATOR_L_BUYOUT_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 145
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "bidPrice" },
    headerText = AUCTIONATOR_L_BID_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "bidPrice" },
    width = 145,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "quantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "quantityFormatted" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_ITEM_LEVEL_COLUMN,
    headerParameters = { "level" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "levelPretty" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "otherSellers" },
    headerText = AUCTIONATOR_L_SELLERS_COLUMN,
    cellTemplate = "AuctionatorTooltipStringCellTemplate",
    cellParameters = { "otherSellers" },
    defaultHide = true,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "owned" },
    headerText = AUCTIONATOR_L_OWNED_COLUMN,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "owned" },
    defaultHide = true,
    width = 70
  },
}

local SEARCH_EVENTS = {
  "ITEM_SEARCH_RESULTS_UPDATED",
  "AUCTION_HOUSE_NEW_BID_RECEIVED",
}

AuctionatorBuyItemDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorBuyItemDataProviderMixin:OnLoad()
  AuctionatorDataProviderMixin.OnLoad(self)

  Auctionator.EventBus:Register(self, {
    Auctionator.Buying.Events.ShowItemBuy,
    Auctionator.Buying.Events.RefreshingItems,
  })
end

function AuctionatorBuyItemDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
  self:Reset()
end

function AuctionatorBuyItemDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
end

function AuctionatorBuyItemDataProviderMixin:ReceiveEvent(eventName, rowData, itemKeyInfo)
  if eventName == Auctionator.Buying.Events.ShowItemBuy then
    -- Used to prevent a sale causing the view to sometimes change to another item
    self.expectedItemKey = rowData.itemKey
  elseif eventName == Auctionator.Buying.Events.RefreshingItems then
    self:Reset()
    self.onSearchStarted()
  end
end

function AuctionatorBuyItemDataProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

function AuctionatorBuyItemDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING_BUY_ITEM)
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  bidPrice = Auctionator.Utilities.NumberComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
  timeLeft = Auctionator.Utilities.NumberComparator,
  owned = Auctionator.Utilities.StringComparator,
  otherSellers = Auctionator.Utilities.StringComparator,
}

function AuctionatorBuyItemDataProviderMixin:UniqueKey(entry)
  return entry.auctionID
end

function AuctionatorBuyItemDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorBuyItemDataProviderMixin:OnEvent(eventName, itemRef)
  if (eventName == "ITEM_SEARCH_RESULTS_UPDATED" and self.expectedItemKey ~= nil and
          Auctionator.Utilities.ItemKeyString(self.expectedItemKey) == Auctionator.Utilities.ItemKeyString(itemRef)
        ) then
    self.onPreserveScroll()
    self:Reset()
    self:AppendEntries(self:ProcessItemResults(itemRef), true)
  elseif eventName == "AUCTION_HOUSE_NEW_BID_RECEIVED" and self.expectedItemKey ~= nil then
    local auctionInfo = C_AuctionHouse.GetAuctionInfoByID(itemRef)
    if Auctionator.Utilities.ItemKeyString(self.expectedItemKey) == Auctionator.Utilities.ItemKeyString(auctionInfo.itemKey) then
      self:GetParent():Search()
    end
  end
end

local function cancelShortcutEnabled()
  return Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT) ~= Auctionator.Config.Shortcuts.NONE
end

function AuctionatorBuyItemDataProviderMixin:ProcessItemResults(itemKey)
  local entries = {}
  local anyOwnedNotLoaded = false

  for index = 1, C_AuctionHouse.GetNumItemSearchResults(itemKey) do
    local resultInfo = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    local entry = Auctionator.Search.GetBuyItemResult(resultInfo)
    -- Test if the auction has been loaded for cancelling
    if resultInfo.containsOwnerItem and (
        not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) or (entry.bidder and C_AuctionHouse.GetCancelCost(entry.auctionID) == 0)
      ) then
      anyOwnedNotLoaded = true
    end

    table.insert(entries, entry)
  end

  -- See comment in ProcessCommodityResults
  if anyOwnedNotLoaded and cancelShortcutEnabled() then
    Auctionator.AH.QueryOwnedAuctions({})
  end

  return entries
end

function AuctionatorBuyItemDataProviderMixin:GetRowTemplate()
  return "AuctionatorBuyItemRowTemplate"
end
