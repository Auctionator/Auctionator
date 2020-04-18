AuctionatorAdvancedSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "ITEM_KEY_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
  "GET_ITEM_INFO_RECEIVED",
}

local ADVANCED_SEARCH_BUS_EVENTS = {
  "SearchResultReady"
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

local function ParseAdvancedSearch(searchString)

  local parsed = Auctionator.Search.SplitAdvancedSearch(searchString)

  return {
    query = {
      searchString = parsed.queryString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      filters = {},
      itemClassFilters = GetItemClassFilters(parsed.filterKey),
      sorts = {},
    },
    extraFilters = {
      itemLevel = {
        min = parsed.minItemLevel,
        max = parsed.maxItemLevel,
      },
      craftLevel = {
        min = parsed.minCraftLevel,
        max = parsed.maxCraftLevel,
      },
      priceRange = {
        min = parsed.minPrice,
        max = parsed.maxPrice,
      },
      exactSearch = ExtractExactSearch(parsed.queryString),
    }
  }
end


function AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:CreateSearchTerm()", term)
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

function AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    C_AuctionHouse.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.waiting = 0
  end
end

function AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return C_AuctionHouse.HasFullBrowseResults() and
         self.waiting == 0
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
  else
    Auctionator.EventBus
      :RegisterSource(self, "advanced search provider mixin")
      :Fire(self, "ProcessorSearchEvent", eventName, ...)
      :UnregisterSource(self)
  end
end

function AuctionatorAdvancedSearchProviderMixin:ReceiveEvent(eventName, browseResult, result)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessProcessors", eventName, browseResult, browseResult.itemKey, result, self.waiting)
  if eventName == "SearchResultReady" and self.waiting > 0 then
    self.waiting = self.waiting - 1
    if result then
      self:AddResults({browseResult})
    else
      self:AddResults({})
    end

    self:HandleTermination()
  end
end

function AuctionatorAdvancedSearchProviderMixin:HandleTermination()
  if self:HasCompleteTermResults() then
    print("ended at 0")
    self:AddResults({})
    Auctionator.EventBus:Unregister(self, ADVANCED_SEARCH_BUS_EVENTS)
    self.registeredForEvents = false
  end
end

function AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorAdvancedSearchProviderMixin:ProcessSearchResults()")
  if not self.registeredForEvents then
    Auctionator.EventBus:Register(self, ADVANCED_SEARCH_BUS_EVENTS)
    self.registeredForEvents = true
  end

  self.waiting = self.waiting + #addedResults
  for _, browseResult in ipairs(addedResults) do
    print("creating", browseResult)

    CreateAndInitFromMixin(
      Auctionator.Search.Processors.ResultMonitorMixin,
      browseResult
    )

    Auctionator.Search.Processors.Create(browseResult, self.currentFilter)
  end

  print("try fire")
  Auctionator.EventBus
    :RegisterSource(self, "advanced search provider mixin")
    :Fire(self, "AllRelatedProcessorsAdded")
    :UnregisterSource(self)

  self:HandleTermination()
end

function AuctionatorAdvancedSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorAdvancedSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
end
