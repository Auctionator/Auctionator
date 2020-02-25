AuctionatorAdvancedSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

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

  local itemClassFilters = {}
  if filterKey~=nil then
    itemClassFilters = GetItemClassFilters(filterKey)
  end

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
      maxItemLevel = maxItemLevel
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
      extraFilters = {}
    }
  end
end

function AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()")

  return function(searchTerm)
    C_AuctionHouse.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
  end
end

function AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()")
  return C_AuctionHouse.HasFullBrowseResults()
end

function AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
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
    if self:FilterItemKey(addedResults[index].itemKey) then
      table.insert(results, addedResults[index].itemKey)
    end
  end

  self:AddResults(results)
end

function AuctionatorAdvancedSearchProviderMixin:FilterItemKey(itemKey)
  if itemKey.itemLevel ~= nil and itemKey.itemLevel ~= 0 then
    if (self.currentFilter.minItemLevel ~= nil and self.currentFilter.minItemLevel>itemKey.itemLevel) then
      return false
    end
    if (self.currentFilter.maxItemLevel ~= nil and self.currentFilter.maxItemLevel<itemKey.itemLevel) then
      return false
    end
  end
  return true
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
