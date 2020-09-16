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

AuctionatorSearchDataProviderMixin = CreateFromMixins(AuctionatorDataProviderMixin)

function AuctionatorSearchDataProviderMixin:OnShow()
  FrameUtil.RegisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Register(self, {
    Auctionator.Selling.Events.SellSearchStart
  })

  self:Reset()
end

function AuctionatorSearchDataProviderMixin:OnHide()
  FrameUtil.UnregisterFrameForEvents(self, SEARCH_EVENTS)
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Selling.Events.SellSearchStart
  })
end

function AuctionatorSearchDataProviderMixin:ReceiveEvent(eventName)
  if eventName == Auctionator.Selling.Events.SellSearchStart then
    self:Reset()
    self.onSearchStarted()
  end
end

function AuctionatorSearchDataProviderMixin:GetTableLayout()
  return SEARCH_PROVIDER_LAYOUT
end

local COMPARATORS = {
  price = Auctionator.Utilities.NumberComparator,
  bidPrice = Auctionator.Utilities.NumberComparator,
  quantity = Auctionator.Utilities.NumberComparator,
  level = Auctionator.Utilities.NumberComparator,
  owned = Auctionator.Utilities.StringComparator,
}

function AuctionatorSearchDataProviderMixin:UniqueKey(entry)
  return entry.auctionID
end

function AuctionatorSearchDataProviderMixin:Sort(fieldName, sortDirection)
  local comparator = COMPARATORS[fieldName](sortDirection, fieldName)

  table.sort(self.results, function(left, right)
    return comparator(left, right)
  end)

  self.onUpdate(self.results)
end

function AuctionatorSearchDataProviderMixin:OnEvent(eventName, itemRef, auctionID)
  if eventName == "COMMODITY_SEARCH_RESULTS_UPDATED" then
    self:Reset()
    self:AppendEntries(self:ProcessCommodityResults(itemRef), true)

  -- Get item search results, excluding individual auction updates (which cause
  -- the display to blank)
  elseif eventName == "ITEM_SEARCH_RESULTS_UPDATED" and auctionID == nil then
    self:Reset()
    self:AppendEntries(self:ProcessItemResults(itemRef), true)

  elseif eventName == "AUCTION_CANCELED" then
    Auctionator.EventBus
      :RegisterSource(self, "AuctionatorSearchDataProviderMixin")
      :Fire(self, Auctionator.Selling.Events.RefreshSearch)
      :UnregisterSource(self)
  end
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
      quantity = resultInfo.quantity,
      level = "0",
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
  if anyOwnedNotLoaded and Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT) ~= Auctionator.Config.Shortcuts.NONE then
    Auctionator.AH.QueryOwnedAuctions({})
  end

  return entries
end

local function cancelShortcutEnabled()
  return Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CANCEL_SHORTCUT) ~= Auctionator.Config.Shortcuts.NONE
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
      timeLeft = resultInfo.timeLeft,
      quantity = resultInfo.quantity,
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
