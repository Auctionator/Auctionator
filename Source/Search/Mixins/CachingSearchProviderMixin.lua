AuctionatorCachingSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local CACHING_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
}

local FILTER_SEARCH_EVENTS = {
  "EXTRA_BROWSE_INFO_RECEIVED",
}

local PROCESSING_PER_FRAME_LIMIT = 80000

local INTERNAL_SEARCH_EVENTS = {
  Auctionator.Search.Events.SearchResultsReady
}

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
      :UnregisterSource(self)
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
    end
  end

  if self.namesWaiting <= 0 and self.gotAllResults then
    self:SearchGroupReady()
  end
end

function AuctionatorCachingSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorCachingSearchProviderMixin:CreateSearchTerm()", term)
  local parsed = Auctionator.Search.SplitAdvancedSearch(term)

  return {
    searchString = parsed.searchString,
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

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    self.currentQuery = searchTerm
    self.currentIndex = 0
    self.waiting = 0
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
  local index = self.currentIndex
  local indexLimit = math.min(#self.fullSearchCache, self.currentIndex + (PROCESSING_PER_FRAME_LIMIT - self.processed))
  local nameCache = self.fullSearchNameCache
  local strFind = string.find
  while index < indexLimit do
    index = index + 1
    if strFind(nameCache[index], lowerName, 1, true) then
      self.waiting = self.waiting + 1
      local filterTracker = CreateAndInitFromMixin(
        Auctionator.Search.Filters.FilterTrackerMixin,
        self.fullSearchCache[index]
      )
      local filters = Auctionator.Search.Filters.Create(self.fullSearchCache[index], self.currentQuery, filterTracker)

      filterTracker:SetWaiting(#filters)
    end
  end
  self.processed = self.processed + index - self.currentIndex
  self.currentIndex = index
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
