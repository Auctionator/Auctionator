local SEARCH_PROVIDER_LAYOUT = {
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "price" },
    headerText = AUCTIONATOR_L_BUYOUT_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "price" },
    width = 140
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "bidPrice" },
    headerText = AUCTIONATOR_L_BID_PRICE,
    cellTemplate = "AuctionatorPriceCellTemplate",
    cellParameters = { "bidPrice" },
    width = 140
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
    cellParameters = { "level" },
  },
  {
    headerTemplate = "AuctionatorStringColumnHeaderTemplate",
    headerParameters = { "timeLeft" },
    headerText = AUCTIONATOR_L_TIME_LEFT,
    cellTemplate = "AuctionatorStringCellTemplate",
    cellParameters = { "timeLeftPretty" },
    defaultHide = true,
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
    width = 70
  },
}

local SEARCH_EVENTS = {
  "COMMODITY_SEARCH_RESULTS_UPDATED",
  "COMMODITY_PURCHASE_SUCCEEDED",
  "ITEM_SEARCH_RESULTS_UPDATED",
}

AuctionatorSearchDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorSearchDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.SellSearchStart,
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Cancelling.Events.RequestCancel,
  })

  self.processCountPerUpdate = 200
  self:Reset()
end

function AuctionatorSearchDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.SellSearchStart,
    Auctionator.Selling.Events.BagItemClicked,
    Auctionator.Cancelling.Events.RequestCancel,
  })
end

function AuctionatorSearchDataProviderMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.Selling.Events.SellSearchStart then
    self:Reset()
    self.onSearchStarted()
  elseif eventName == Auctionator.Selling.Events.BagItemClicked then
    self.onResetScroll()
  elseif eventName == Auctionator.Cancelling.Events.RequestCancel then
    self:RegisterEvent("AUCTION_CANCELED")
  end
end

function AuctionatorSearchDataProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

function AuctionatorSearchDataProviderMixin:GetColumnHideStates()
  return Auctionator.Config.Get(Auctionator.Config.Options.COLUMNS_SELLING_SEARCH)
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

function AuctionatorSearchDataProviderMixin:UniqueKey(entry)
  return entry.auctionID
end

function AuctionatorSearchDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self:SetDirty()
end

function AuctionatorSearchDataProviderMixin:OnEvent(eventName, itemRef, auctionID)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:Reset()
    self:AppendEntries(self:ProcessCommodityResults(itemRef), true)

  -- Get item search results, excluding individual auction updates (which cause
  -- the display to blank)
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" then
    self.onPreserveScroll()
    self:Reset()
    self:AppendEntries(self:ProcessItemResults(itemRef), true)

  elseif eventName == "COMMODITY_PURCHASE_SUCCEEDED" then
    self:RefreshView()

  elseif eventName == "AUCTION_CANCELED" then
    self:UnregisterEvent("AUCTION_CANCELED")

    self:RefreshView()
  end
end

function AuctionatorSearchDataProviderMixin:RefreshView()
  self.onPreserveScroll()
  Auctionator.EventBus
    :RegisterSource(self, "AuctionatorSearchDataProviderMixin")
    :Fire(self, Auctionator.Selling.Events.RefreshSearch)
    :UnregisterSource(self)
end

local function cancelShortcutEnabled()
  return Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT) ~= Auctionator.Config.Shortcuts.NONE
end

function AuctionatorSearchDataProviderMixin:ProcessCommodityResults(itemID)
  local entries = {}
  local anyOwnedNotLoaded = false

  for index = C_AuctionHouse.GetNumCommoditySearchResults(itemID), 1, -1 do
    local resultInfo = C_AuctionHouse.GetCommoditySearchResultInfo(itemID, index)
    local entry = {
      price = resultInfo.unitPrice,
      bidPrice = nil,
      owners = resultInfo.owners,
      otherSellers = Auctionator.Utilities.StringJoin(resultInfo.owners, ", "),
      quantity = resultInfo.quantity,
      quantityFormatted = Auctionator.Utilities.DelimitThousands(resultInfo.quantity),
      level = "0",
      timeLeftPretty = Auctionator.Utilities.FormatTimeLeft(resultInfo.timeLeftSeconds),
      timeLeft = resultInfo.timeLeftSeconds or 0, --Used in sorting
      auctionID = resultInfo.auctionID,
      itemID = itemID,
      itemType = Auctionator.Constants.ITEM_TYPES.COMMODITY,
      canBuy = not (resultInfo.containsOwnerItem or resultInfo.containsAccountItem)
    }

    if resultInfo.containsOwnerItem then
      -- Test if the auction has been loaded for cancelling
      if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
        anyOwnedNotLoaded = true
      end

      entry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU)
      entry.owned = AUCTIONATOR_L_UNDERCUT_YES

    else
      entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end

    table.insert(entries, entry)
  end

  -- To cancel an owned auction it must have been loaded by QueryOwnedAuctions.
  -- Rather than call it unnecessarily (which wastes a request) it is only
  -- called if an auction exists that hasn't been loaded for cancelling yet.
  -- If a user really really wants to avoid an extra request they can turn the
  -- feature off.
  if anyOwnedNotLoaded and cancelShortcutEnabled() then
    Auctionator.AH.QueryOwnedAuctions({})
  end

  return entries
end

function AuctionatorSearchDataProviderMixin:ProcessItemResults(itemKey)
  local entries = {}
  local anyOwnedNotLoaded = false

  for index = C_AuctionHouse.GetNumItemSearchResults(itemKey), 1, -1 do
    local resultInfo = C_AuctionHouse.GetItemSearchResultInfo(itemKey, index)
    local entry = {
      price = resultInfo.buyoutAmount,
      bidPrice = resultInfo.bidAmount,
      level = tostring(resultInfo.itemKey.itemLevel or 0),
      owners = resultInfo.owners,
      otherSellers = Auctionator.Utilities.StringJoin(resultInfo.owners, ", "),
      timeLeftPretty = Auctionator.Utilities.FormatTimeLeftBand(resultInfo.timeLeft),
      timeLeft = resultInfo.timeLeft, --Used in sorting and the vanilla AH tooltip code
      quantity = resultInfo.quantity,
      quantityFormatted = Auctionator.Utilities.DelimitThousands(resultInfo.quantity),
      itemLink = resultInfo.itemLink,
      auctionID = resultInfo.auctionID,
      itemType = Auctionator.Constants.ITEM_TYPES.ITEM,
      canBuy = resultInfo.buyoutAmount ~= nil and not (resultInfo.containsOwnerItem or resultInfo.containsAccountItem)
    }

    if resultInfo.itemKey.battlePetSpeciesID ~= 0 and entry.itemLink ~= nil then
      entry.level = tostring(Auctionator.Utilities.GetPetLevelFromLink(entry.itemLink))
    end

    local qualityColor = Auctionator.Utilities.GetQualityColorFromLink(entry.itemLink)
    entry.level = "|c" .. qualityColor .. entry.level .. "|r"

    if resultInfo.containsOwnerItem then
      -- Test if the auction has been loaded for cancelling
      if not C_AuctionHouse.CanCancelAuction(resultInfo.auctionID) then
        anyOwnedNotLoaded = true
      end

      entry.otherSellers = GREEN_FONT_COLOR:WrapTextInColorCode(AUCTION_HOUSE_SELLER_YOU)
      entry.owned = AUCTIONATOR_L_UNDERCUT_YES

    else
      entry.owned = GRAY_FONT_COLOR:WrapTextInColorCode(AUCTIONATOR_L_UNDERCUT_NO)
    end

    table.insert(entries, entry)
  end

  -- See comment in ProcessCommodityResults
  if anyOwnedNotLoaded and cancelShortcutEnabled() then
    Auctionator.AH.QueryOwnedAuctions({})
  end

  return entries
end

function AuctionatorSearchDataProviderMixin:GetRowTemplate()
  return "AuctionatorSellSearchRowTemplate"
end
