AuctionatorAdvancedSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
}

local function ExtractExactSearch(queryString)
  return string.match(queryString, "^\"(.*)\"$")
end

local function GetItemClassFilters(filterKey)
  local lookup = Auctionator.Search.FilterLookup[filterKey]
  if lookup ~= nil then
    return lookup.filter
  else
    return {}
  end
end

local function IsCompoundSearch(searchString)
  if searchString == nil then
    return false;
  else
    return Auctionator.Utilities.StringContains (searchString, Auctionator.Constants.AdvancedSearchDivider);
  end
end

local function ParseCompoundSearch(searchString)
  local delimiter = Auctionator.Constants.AdvancedSearchDivider

  local queryString, filterKey, minItemLevel, maxItemLevel, minLevel, maxLevel =
    strsplit( delimiter, searchString )

  -- A nil queryString causes a disconnect, but an empty one doesn't
  if queryString == nil then
    queryString = ""
  end

  local itemClassFilters = GetItemClassFilters(filterKey)

  minLevel = tonumber( minLevel )
  maxLevel = tonumber( maxLevel )
  minItemLevel = tonumber( minItemLevel )
  maxItemLevel = tonumber( maxItemLevel )

  if minLevel == 0 then
    minLevel = nil
  end

  if maxLevel == 0 then
    maxLevel = nil
  end

  if minItemLevel == 0 then
    minItemLevel = nil
  end

  if maxItemLevel == 0 then
    maxItemLevel = nil
  end

  local exactSearch = ExtractExactSearch(queryString)

  return {
    query = {
      searchString = queryString,
      minLevel = minLevel,
      maxLevel = maxLevel,
      filters = {},
      itemClassFilters = itemClassFilters,
      sorts = {},
    },
    extraFilters = {
      minItemLevel = minItemLevel,
      maxItemLevel = maxItemLevel,
      exactSearch = exactSearch,
    }
  }
end

function AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm()", term)
  if IsCompoundSearch(term) then
    return ParseCompoundSearch(term)
  else
    return  {
      query = {
        searchString = term,
        filters = {},
        itemClassFilters = {},
        sorts = {},
      },
      extraFilters = {
        exactSearch = ExtractExactSearch(term)
      }
    }
  end
end

function AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    C_AuctionHouse.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.itemKeyInfoQueue = {}
  end
end

function AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return C_AuctionHouse.HasFullBrowseResults() and #(self.itemKeyInfoQueue) == 0
end

function AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "ITEM_KEY_ITEM_INFO_RECEIVED" then
    self:ProcessItemKeyInfo(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults()")

  local results = {}

  for index = 1, #addedResults do
    -- Run filter checks on every item key. Some might not be added to the
    -- results yet, but when the relevant information arrives in an event
    if self:FilterByItemLevel(addedResults[index].itemKey) then
      if self:FilterByExact(addedResults[index].itemKey) then
        table.insert(results, addedResults[index].itemKey)
      end
    end
  end

  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:ProcessItemKeyInfo(itemID)
  --Event for missing info received about itemID.
  for index, itemKey in ipairs(self.itemKeyInfoQueue) do
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)
    if itemKeyInfo then
      --Remove key from list of those with missing info
      table.remove(self.itemKeyInfoQueue, index)

    --Only exact search uses this info, and the event won't have been queued
    --otherwise.
      if self:ExactMatchCheck(itemKeyInfo) then
        self:AddResults({itemKey})
      else
        --Post empty results, so the mixin supplying it runs
        --self:HasCompleteTermResults() and can see if the search is complete
        self:AddResults({})
      end

      --Only one new result per event
      break
    end
  end
end

function AuctionatorAdvancedSearchProviderMixin:FilterByItemLevel(itemKey)
  -- Check for 0 is to avoid filtering issues with glitchy AH APIs.
  if itemKey.itemLevel ~= nil and itemKey.itemLevel ~= 0 then
    --Minimum item level check
    if (self.currentFilter.minItemLevel ~= nil and self.currentFilter.minItemLevel>itemKey.itemLevel) then
      return false
    end
    --Maximum item level check
    if (self.currentFilter.maxItemLevel ~= nil and self.currentFilter.maxItemLevel<itemKey.itemLevel) then
      return false
    end
  end
  return true
end

function AuctionatorAdvancedSearchProviderMixin:FilterByExact(itemKey)
  if self.currentFilter.exactSearch ~= nil then
    local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey)

    if itemKeyInfo == nil then
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByExact Missing itemKeyInfo")

      --Put key in the queue for completing filtering later in an
      --ITEM_KEY_ITEM_INFO_RECEIVED event
      table.insert(self.itemKeyInfoQueue, itemKey)

      return false
    else
      Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:FilterByExact Got itemKeyInfo", itemKeyInfo.itemName)

      return self:ExactMatchCheck(itemKeyInfo)
    end
  end
  return true
end

function AuctionatorAdvancedSearchProviderMixin:ExactMatchCheck(itemKeyInfo)
  return (string.lower(itemKeyInfo.itemName) == string.lower(self.currentFilter.exactSearch))
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
