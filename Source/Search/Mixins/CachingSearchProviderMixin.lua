-- Used to search for 100s of items simultaneously.
-- This provider does a blank search of the AH, then caches the results, and
-- searches the cache for the items being searched for.
AuctionatorCachingSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local CACHING_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
}

local FILTER_SEARCH_EVENTS = {
  "EXTRA_BROWSE_INFO_RECEIVED",
}

-- Limits per-frame processing to avoid freezing the game
-- Increasing these values usually speeds up the search, but drops the frame rate.
local PROCESSING_PER_FRAME_LIMIT = 80000
local FILTERS_PER_FRAME_LIMIT = 1000

local INTERNAL_SEARCH_EVENTS = {
  Auctionator.Search.Events.SearchResultsReady
}

function AuctionatorCachingSearchProviderMixin:InitializeNewSearchGroup()
  self:RegisterEvents(CACHING_SEARCH_EVENTS)

  -- Information about caching the blank search.
  self.blankSearchResults = {
    cache = {},
    names = {},
    namesWaiting = 0,
    gotCompleteCache = false,
    announcedReady = false,
  }
  -- Used to keep track of how many items in the cache have been processed this
  -- frame, and prevent it exceeding the *_PER_FRAME_LIMIT constants.
  self.processed = 0
  self.filtersThisFrame = 0

  Auctionator.AH.SendBrowseQuery({
    searchString = "",
    filters = {},
    itemClassFilters = {},
    sorts = Auctionator.Constants.SHOPPING_LIST_SORTS,
  })
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
      :RegisterSource(self, "AuctionatorCachingSearchProviderMixin")
      :Fire(self, Auctionator.Search.Events.BlizzardInfo, eventName, ...)
      :UnregisterSource(self)
  end
end

local function CleanSearchString(searchString)
  return string.gsub(string.lower(searchString), "\"", "")
end

-- Cache the results of the blank search with the associated item names for the
-- results. Called multiple times to process each batch of results.
function AuctionatorCachingSearchProviderMixin:CacheSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:CacheSearchResults()")

  local resultsInfo = self.blankSearchResults
  resultsInfo.gotCompleteCache = Auctionator.AH.HasFullBrowseResults()
  resultsInfo.namesWaiting = resultsInfo.namesWaiting + #addedResults

  for _, result in ipairs(addedResults) do
    if result.totalQuantity ~= 0 then
      table.insert(resultsInfo.cache, result)
      local index = #resultsInfo.cache
      table.insert(resultsInfo.names, "")
      Auctionator.AH.GetItemKeyInfo(result.itemKey, function(itemKeyInfo)
        resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
        resultsInfo.names[index] = CleanSearchString(itemKeyInfo.itemName)
        if resultsInfo.namesWaiting <= 0 and resultsInfo.gotCompleteCache then
          resultsInfo.announcedReady = true
          self:UnregisterEvents(CACHING_SEARCH_EVENTS)
          self:SearchGroupReady()
        end
      end)
    else
      resultsInfo.namesWaiting = resultsInfo.namesWaiting - 1
    end
  end

  if resultsInfo.namesWaiting <= 0 and resultsInfo.gotCompleteCache and not resultsInfo.announcedReady then
    self:UnregisterEvents(CACHING_SEARCH_EVENTS)
    self:SearchGroupReady()
  end
end

function AuctionatorCachingSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:CreateSearchTerm()", term)
  local parsed = Auctionator.Search.SplitAdvancedSearch(term)

  return {
    searchString = CleanSearchString(parsed.searchString),
    itemLevel = {
      min = parsed.minItemLevel,
      max = parsed.maxItemLevel,
    },
    usableLevel = {
      min = parsed.minLevel,
      max = parsed.maxLevel,
    },
    itemClassFilters = Auctionator.Search.GetItemClassCategories(parsed.categoryKey),
    craftedLevel = {
      min = parsed.minCraftedLevel,
      max = parsed.maxCraftedLevel,
    },
    price = {
      min = parsed.minPrice,
      max = parsed.maxPrice,
    },
    exactSearch = (parsed.isExact and parsed.searchString) or nil,
  }
end

function AuctionatorCachingSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:GetSearchProvider()")

  --Start a search of the cache for searchTerm
  return function(searchTerm)
    self.currentQuery = searchTerm
    self.currentIndex = 0
    self.waiting = 0
    self.queuedResults = {}
    self:SetScript("OnUpdate", self.OnUpdate)
    self:ProcessCurrentSearch()
  end
end

function AuctionatorCachingSearchProviderMixin:HasCompleteTermResults()
  return self.waiting <= 0 and self.currentIndex >= #self.blankSearchResults.cache
end

function AuctionatorCachingSearchProviderMixin:ProcessCurrentSearch()
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:ProcessSearchResults()")

  if not self.registeredForEvents then
    self.registeredForEvents = true
    Auctionator.EventBus:Register(self, INTERNAL_SEARCH_EVENTS)
  end

  if self.filtersThisFrame >= FILTERS_PER_FRAME_LIMIT then
    return
  end

  -- These parameters are cached in locals for performance. Testing indicates
  -- time savings of at least 50% just from this.
  local searchString = self.currentQuery.searchString
  local index = self.currentIndex
  local indexLimit = math.min(
    #self.blankSearchResults.cache,
    self.currentIndex + (PROCESSING_PER_FRAME_LIMIT - self.processed)
  )
  local nameCache = self.blankSearchResults.names
  local strFind = string.find
  while index < indexLimit do
    index = index + 1
    -- Search by name first before activating the filters (significant
    -- performance boost from this)
    if strFind(nameCache[index], searchString, 1, true) then
      self.waiting = self.waiting + 1
      -- Create and run the filters normally (like
      -- AuctionatorDirectSearchProvider)
      local filterTracker = CreateAndInitFromMixin(
        Auctionator.Search.Filters.FilterTrackerMixin,
        self.blankSearchResults.cache[index]
      )
      local filters = Auctionator.Search.Filters.Create(self.blankSearchResults.cache[index], self.currentQuery, filterTracker)
      self.filtersThisFrame = self.filtersThisFrame + #filters

      filterTracker:SetWaiting(#filters)

      if self.filtersThisFrame >= FILTERS_PER_FRAME_LIMIT then
        break
      end
    end
  end
  self.processed = self.processed + index - self.currentIndex
  self.currentIndex = index

  if self:HasCompleteTermResults() then
    self:PostCompleteResults()
  end
end

function AuctionatorCachingSearchProviderMixin:OnUpdate(elapsed)
  self.processed = 0
  self.filtersThisFrame = 0
  if not self:HasCompleteTermResults() then
    self:ProcessCurrentSearch()
  else
    self:SetScript("OnUpdate", nil)
  end
end

function AuctionatorCachingSearchProviderMixin:ReceiveEvent(eventName, results)
  if eventName == Auctionator.Search.Events.SearchResultsReady then
    self.waiting = self.waiting - 1

    if results[1] then
      -- Make result safe for modification (which happens in ItemKeyLoadingMixin)
      local cleanResult = {}
      for k, v in pairs(results[1]) do
        cleanResult[k] = v
      end
      table.insert(self.queuedResults, cleanResult)
    end

    if self:HasCompleteTermResults() then
      self:PostCompleteResults()
    end
  end
end

function AuctionatorCachingSearchProviderMixin:PostCompleteResults()
  self.registeredForEvents = false
  Auctionator.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
  self:AddResults(self.queuedResults)
end


function AuctionatorCachingSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(FILTER_SEARCH_EVENTS)
end

function AuctionatorCachingSearchProviderMixin:UnregisterProviderEvents()
  if self.registeredForEvents then
    self.registeredForEvents = false
    Auctionator.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
  end
  self:UnregisterEvents(FILTER_SEARCH_EVENTS)
  self:UnregisterEvents(CACHING_SEARCH_EVENTS)
  self:SetScript("OnUpdate", nil)
end
