local SHOPPING_LIST_TABLE_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "minPrice" },
    headerText = AUCTIONATOR_L_RESULTS_PRICE_COLUMN,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "minPrice" },
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "name" },
    headerText = AUCTIONATOR_L_RESULTS_NAME_COLUMN,
    cellTemplate = "AuctionatorItemKeyCellTemplate"
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "isOwned" },
    headerText = AUCTIONATOR_L_OWNED_COLUMN,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "isOwned" },
    defaultHide = true,
    width = 70,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "isTop" },
    headerText = AUCTIONATOR_L_IS_TOP_COLUMN,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "isTop" },
    defaultHide = true,
    width = 70,
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerText = AUCTIONATOR_L_RESULTS_AVAILABLE_COLUMN,
    headerParameters = { "totalQuantity" },
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "totalQuantityString" },
    width = 70
  }
}

AuctionatorShoppingDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin, AuctionatorItemStringLoadingMixin)

function AuctionatorShoppingDataProviderMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingDataProviderMixin:OnLoad()")

  self:SetUpEvents()

  AuctionatorDataProviderMixin.OnLoad(self)
  AuctionatorItemStringLoadingMixin.OnLoad(self)
end

function AuctionatorShoppingDataProviderMixin:SetUpEvents()
  Auctionator.EventBus:RegisterSource(self, "Shopping List Data Provider")

  Auctionator.EventBus:Register( self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded,
    Auctionator.Shopping.Events.ListSearchIncrementalUpdate
  })
end

function AuctionatorShoppingDataProviderMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self:Reset()
    self.onSearchStarted()
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self:AppendEntries(self:AddDetails(eventData), true)
  elseif eventName == Auctionator.Shopping.Events.ListSearchIncrementalUpdate then
    self:AppendEntries(self:AddDetails(eventData))
  end
end

function AuctionatorShoppingDataProviderMixin:AddDetails(entries)
  for _, entry in ipairs(entries) do
    if entry.containsOwnerItem then
      entry.isOwned = AUCTIONATOR_L_UNDERCUT_YES
    else
      entry.isOwned = ""
    end

    if entry.isTopItem then
      entry.isTop = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_YES)
    else
      entry.isTop = RED_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end

    if not entry.complete then
      entry.totalQuantityString = AUCTIONATOR_L_UNDERCUT_UNKNOWN
    else
      entry.totalQuantityString = tostring(entry.totalQuantity)
    end
  end

  return entries
end

function AuctionatorShoppingDataProviderMixin:UniqueKey(entry)
  return entry.itemString
end

local COMPARATORS = {
  minPrice = Auctionator.Utilities.NumberComparator,
  name = Auctionator.Utilities.StringComparator,
  isOwned = Auctionator.Utilities.StringComparator,
  totalQuantity = Auctionator.Utilities.NumberComparator
}

function AuctionatorShoppingDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorShoppingDataProviderMixin:GetTableLayout()
  return SHOPPING_LIST_TABLE_LAYOUT
end

function AuctionatorShoppingDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SHOPPING)
end

function AuctionatorShoppingDataProviderMixin:GetRowTemplate()
  return "AuctionatorShoppingResultsRowTemplate"
end
