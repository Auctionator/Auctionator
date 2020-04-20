AuctionatorAdvancedSearchRank3 = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
  "GET_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
}

local INTERNAL_SEARCH_EVENTS = {
  Auctionator.Search.Events.SearchResultsReady
}

local function ExtractExactSearch(queryString)
  return string.match(queryString, "^\"(.*)\"$")
end

local function GetItemClassCategories(categoryKey)
  local lookup = Auctionator.Search.CategoryLookup[categoryKey]
  if lookup ~= nil then
    return lookup.category
  else
    return {}
  end
end

local function ParseAdvancedSearch(searchString)

  local parsed = Auctionator.Search.SplitAdvancedSearch(searchString)

  return {
    query = {
      searchString = parsed.queryString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      filters = {},
      itemClassFilters = GetItemClassCategories(parsed.categoryKey),
      sorts = {},
    },
    extraFilters = {
      itemLevel = {
        min = parsed.minItemLevel,
        max = parsed.maxItemLevel,
      },
      craftedLevel = {
        min = parsed.minCraftedLevel,
        max = parsed.maxCraftedLevel,
      },
      price = {
        min = parsed.minPrice,
        max = parsed.maxPrice,
      },
      exactSearch = ExtractExactSearch(parsed.queryString),
    }
  }
end

function AuctionatorAdvancedSearchRank3:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchRank3:CreateSearchTerm()", term)
  if Auctionator.Search.IsAdvancedSearch(term) then
    return ParseAdvancedSearch(term)
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

function AuctionatorAdvancedSearchRank3:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchRank3:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    C_AuctionHouse.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.waiting = 0
  end
end

function AuctionatorAdvancedSearchRank3:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchRank3:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return C_AuctionHouse.HasFullBrowseResults() and self.waiting == 0
end

function AuctionatorAdvancedSearchRank3:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchRank3:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  else
    Auctionator.EventBus
      :RegisterSource(self, "Advanced Search Provider")
      :Fire(self, Auctionator.Search.Events.BlizzardInfo, eventName, ...)
      :UnregisterSource(self)
  end
end

function AuctionatorAdvancedSearchRank3:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchRank3:ProcessSearchResults()")
  
  if not self.registeredForEvents then
    self.registeredForEvents = true
    Auctionator.EventBus:Register(self, INTERNAL_SEARCH_EVENTS)
  end
  self.waiting = self.waiting + #addedResults
  for index = 1, #addedResults do
    local filterTracker = CreateAndInitFromMixin(
      Auctionator.Search.Filters.FilterTrackerMixin,
      addedResults[index]
    )
    local filters = Auctionator.Search.Filters.Create(addedResults[index], self.currentFilter)

    filterTracker:SetWaiting(#filters)
  end
end

function AuctionatorAdvancedSearchRank3:ReceiveEvent(eventName, results)
  if eventName == Auctionator.Search.Events.SearchResultsReady then
    self.waiting = self.waiting - 1
    self:AddResults(results)
  end
end


function AuctionatorAdvancedSearchRank3:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchRank3:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
