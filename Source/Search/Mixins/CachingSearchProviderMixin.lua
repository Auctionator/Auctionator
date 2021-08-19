AuctionatorCachingSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local CACHING_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
}

local FILTER_SEARCH_EVENTS = {
  "EXTRA_BROWSE_INFO_RECEIVED",
}

local PROCESSING_PER_FRAME_LIMIT = 20000

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

local function CleanQueryString(queryString)
  -- Remove "" that are used in exact searches as it causes some searches to
  -- fail when they would otherwise work, example "Steak a la Mode"
  return string.gsub(string.gsub(queryString, "^\"", ""), "\"$", "")
end

local function ParseAdvancedSearch(searchString)

  local parsed = Auctionator.Search.SplitAdvancedSearch(searchString)

  return {
    searchString = CleanQueryString(parsed.queryString),
    itemLevel = {
      min = parsed.minItemLevel,
      max = parsed.maxItemLevel,
    },
    usableLevel = {
      min = parsed.minLevel,
      max = parsed.maxLevel,
    },
    itemClassFilters = GetItemClassCategories(parsed.categoryKey),
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
end

function AuctionatorCachingSearchProviderMixin:InitializeNewSearchGroup()
  Auctionator.AH.SendBrowseQuery({searchString = "", sorts = {}, filters = {}, itemClassFilters = {}})
  self.fullSearchCache = {}
  self.fullSearchNameCache = {}
  self.namesWaiting = 0
  self.doingCaching = true
  self.gotAllResults = false
  self.processed = 0
  self:RegisterEvents(CACHING_SEARCH_EVENTS)
end

function AuctionatorCachingSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:CacheSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:CacheSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  else
      Auctionator.EventBus
      :RegisterSource(self, "Advanced Search Provider")
      :Fire(self, Auctionator.Search.Events.BlizzardInfo, eventName, ...)
      --:UnregisterSource(self) Unregistering here breaks shopping list events
  end
end

function AuctionatorCachingSearchProviderMixin:CacheSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:CacheSearchResults()")

  if not self.doingCaching then
    return
  end

  self.gotAllResults = Auctionator.AH.HasFullBrowseResults()
  self.namesWaiting = self.namesWaiting + #addedResults

  for _, result in ipairs(addedResults) do
    if result.totalQuantity ~= 0 then
      table.insert(self.fullSearchCache, result)
      local index = #self.fullSearchCache
      table.insert(self.fullSearchNameCache, "")
      Auctionator.AH.GetItemKeyInfo(result.itemKey, function(itemKeyInfo)
        self.namesWaiting = self.namesWaiting - 1
        self.fullSearchNameCache[index] = string.lower(itemKeyInfo.itemName)
        if self.namesWaiting <= 0 and self.gotAllResults then
          self.doingCaching = false
          self:SearchGroupReady()
        end
      end)
    else
      self.namesWaiting = self.namesWaiting - 1
      if self.namesWaiting <= 0 and self.gotAllResults then
        self:SearchGroupReady()
      end
    end
  end
end

function AuctionatorCachingSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:CreateSearchTerm()", term)
  if Auctionator.Search.IsAdvancedSearch(term) then
    return ParseAdvancedSearch(term)
  else
    return  {
      searchString = CleanQueryString(term),
      exactSearch = ExtractExactSearch(term)
    }
  end
end

function AuctionatorCachingSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    self.currentQuery = searchTerm
    self.currentIndex = 0
    self.waiting = #self.fullSearchCache
    self.resultsWaiting = {}
    self:SetScript("OnUpdate", self.OnUpdate)
    self:ProcessCurrentSearch()
  end
end

function AuctionatorCachingSearchProviderMixin:HasCompleteTermResults()
  return self.waiting <= 0 and self.currentIndex >= #self.fullSearchCache
end

function AuctionatorCachingSearchProviderMixin:ProcessCurrentSearch()
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:ProcessSearchResults()")

  if not self.registeredForEvents then
    self.registeredForEvents = true
    Auctionator.EventBus:Register(self, INTERNAL_SEARCH_EVENTS)
  end
  local lowerName = string.lower(self.currentQuery.searchString)
  while self.currentIndex < #self.fullSearchCache and self.processed < PROCESSING_PER_FRAME_LIMIT do
    self.currentIndex = self.currentIndex + 1
    self.processed = self.processed + 1
    self.waiting = self.waiting - 1
    if string.find(self.fullSearchNameCache[self.currentIndex], lowerName, 1, true) then
      self.waiting = self.waiting + 1
      local filterTracker = CreateAndInitFromMixin(
        Auctionator.Search.Filters.FilterTrackerMixin,
        self.fullSearchCache[self.currentIndex]
      )
      local filters = Auctionator.Search.Filters.Create(self.fullSearchCache[self.currentIndex], self.currentQuery, filterTracker)

      filterTracker:SetWaiting(#filters)
    end
  end
  if self:HasCompleteTermResults() then
    self:AddResults(self.resultsWaiting)
  end
end

function AuctionatorCachingSearchProviderMixin:OnUpdate(elapsed)
  self.processed = 0
  if not self:HasCompleteTermResults() then
    self:ProcessCurrentSearch()
  else
    self:SetScript("OnUpdate", nil)
  end
end

function AuctionatorCachingSearchProviderMixin:ReceiveEvent(eventName, results)
  if eventName == Auctionator.Search.Events.SearchResultsReady then
    self.waiting = self.waiting - 1
    table.insert(self.resultsWaiting, results[1])
    if self:HasCompleteTermResults() then
      self.registeredForEvents = false
      Auctionator.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
      self:AddResults(self.resultsWaiting)
    end
  end
end


function AuctionatorCachingSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(FILTER_SEARCH_EVENTS)
end

function AuctionatorCachingSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(FILTER_SEARCH_EVENTS)
end
