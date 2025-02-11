AuctionatorDirectSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local ADVANCED_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE",
  "GET_ITEM_INFO_RECEIVED",
  "EXTRA_BROWSE_INFO_RECEIVED",
}

local INTERNAL_SEARCH_EVENTS = {
  Auctionator.Search.Events.SearchResultsReady
}

local QUALITY_TO_FILTER = {
  [Enum.ItemQuality.Poor] = Enum.AuctionHouseFilter.PoorQuality,
  [Enum.ItemQuality.Common] = Enum.AuctionHouseFilter.CommonQuality,
  [Enum.ItemQuality.Uncommon] = Enum.AuctionHouseFilter.UncommonQuality,
  [Enum.ItemQuality.Rare] = Enum.AuctionHouseFilter.RareQuality,
  [Enum.ItemQuality.Epic] = Enum.AuctionHouseFilter.EpicQuality,
  [Enum.ItemQuality.Legendary] = Enum.AuctionHouseFilter.LegendaryQuality,
  [Enum.ItemQuality.Artifact] = Enum.AuctionHouseFilter.ArtifactQuality,
}

local function GetQualityFilters(quality)
  if QUALITY_TO_FILTER[quality] ~= nil then
    return { QUALITY_TO_FILTER[quality] }
  else
    return {}
  end
end

function AuctionatorDirectSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:CreateSearchTerm()", term)

  local parsed = Auctionator.Search.SplitAdvancedSearch(term)

  return {
    query = {
      searchString = parsed.searchString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      filters = GetQualityFilters(parsed.quality),
      itemClassFilters = Auctionator.Search.GetItemClassCategories(parsed.categoryKey),
      sorts = Auctionator.Constants.ShoppingSorts,
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
      exactSearch = (parsed.isExact and parsed.searchString) or nil,
      expansion = parsed.expansion,
      tier = parsed.tier,
    },
    resultMetadata = {
      quantity = parsed.quantity,
    }
  }
end

function AuctionatorDirectSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    Auctionator.AH.SendBrowseQuery(searchTerm.query)
    self.currentFilter = searchTerm.extraFilters
    self.resultMetadata = searchTerm.resultMetadata
    self.waiting = 0
  end
end

function AuctionatorDirectSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:HasCompleteTermResults()")

  --Loaded all the terms from API, and we have filtered every item
  return Auctionator.AH.HasFullBrowseResults() and self.waiting == 0
end

function AuctionatorDirectSearchProviderMixin:GetCurrentEmptyResult()
  return Auctionator.Search.GetEmptyResult(self:GetCurrentSearchParameter(), self:GetCurrentSearchIndex())
end

function AuctionatorDirectSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

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
      :RegisterSource(self, "AuctionatorDirectSearchProviderMixin")
      :Fire(self, Auctionator.Search.Events.BlizzardInfo, eventName, ...)
      :UnregisterSource(self)
  end
end

function AuctionatorDirectSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:ProcessSearchResults()")
  
  if not self.registeredForEvents then
    self.registeredForEvents = true
    Auctionator.EventBus:Register(self, INTERNAL_SEARCH_EVENTS)
  end

  if not Auctionator.AH.HasFullBrowseResults() then
    Auctionator.AH.RequestMoreBrowseResults()
  end

  self.waiting = self.waiting + #addedResults
  for index = 1, #addedResults do
    local filterTracker = CreateAndInitFromMixin(
      Auctionator.Search.Filters.FilterTrackerMixin,
      addedResults[index]
    )
    addedResults[index].purchaseQuantity = self.resultMetadata.quantity
    local filters = Auctionator.Search.Filters.Create(addedResults[index], self.currentFilter, filterTracker)

    filterTracker:SetWaiting(#filters)
  end

  if #addedResults == 0 then
    self:AddResults({})
  end
end

function AuctionatorDirectSearchProviderMixin:ReceiveEvent(eventName, results)
  if eventName == Auctionator.Search.Events.SearchResultsReady then
    self.waiting = self.waiting - 1
    if self:HasCompleteTermResults() then
      self.registeredForEvents = false
      Auctionator.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
    end
    self:AddResults(results)
  end
end


function AuctionatorDirectSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(ADVANCED_SEARCH_EVENTS)
end

function AuctionatorDirectSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(ADVANCED_SEARCH_EVENTS)
  if self.registeredForEvents then
    self.registeredForEvents = false
    Auctionator.EventBus:Unregister(self, INTERNAL_SEARCH_EVENTS)
  end
end
