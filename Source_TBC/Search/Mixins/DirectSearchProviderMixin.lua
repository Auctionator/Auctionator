AuctionatorDirectSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local SEARCH_EVENTS = {
  Auctionator.AH.Events.ScanResultsUpdate,
  Auctionator.AH.Events.ScanAborted,
}

local function GetMinPrice(entries)
  local minPrice = nil
  for _, entry in ipairs(entries) do
    local buyout = entry.info[Auctionator.Constants.AuctionItemInfo.Buyout] / entry.info[Auctionator.Constants.AuctionItemInfo.Quantity]
    if buyout ~= 0 then
      if minPrice == nil then
        minPrice = buyout
      else
        minPrice = math.min(minPrice, buyout)
      end
    end
  end
  return math.ceil(minPrice or 0)
end

local function GetQuantity(entries)
  local total = 0
  for _, entry in ipairs(entries) do
    total = total + entry.info[Auctionator.Constants.AuctionItemInfo.Quantity]
  end
  return total
end

function AuctionatorDirectSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:CreateSearchTerm()", term)

  local parsed = Auctionator.Search.SplitAdvancedSearch(term)

  return {
    query = {
      searchString = parsed.searchString,
      minLevel = parsed.minLevel,
      maxLevel = parsed.maxLevel,
      itemClassFilters = Auctionator.Search.GetItemClassCategories(parsed.categoryKey),
      isExact = parsed.isExact,
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
    }
  }
end

function AuctionatorDirectSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:GetSearchProvider()")

  --Run the query, and save extra filter data for processing
  return function(searchTerm)
    self.gotAllResults = false
    self.currentFilter = searchTerm.extraFilters
    self.resultsByKey = {}
    self.individualResults = {}

    Auctionator.AH.QueryAuctionItems(searchTerm.query)
  end
end

function AuctionatorDirectSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:HasCompleteTermResults()")

  return self.gotAllResults
end

function AuctionatorDirectSearchProviderMixin:GetCurrentEmptyResult()
  return Auctionator.Search.GetEmptyResult(self:GetCurrentSearchParameter(), self:GetCurrentSearchIndex())
end

function AuctionatorDirectSearchProviderMixin:AddFinalResults()
  local results = {}
  local waiting = #(Auctionator.Utilities.TableKeys(self.resultsByKey))
  local completed = false
  local function DoComplete()
    table.sort(results, function(a, b)
      return a.minPrice > b.minPrice
    end)
    Auctionator.Search.GroupResultsForDB(self.individualResults)
    self:AddResults(results)
  end

  for key, entries in pairs(self.resultsByKey) do
    local possibleResult = {
      itemString = key,
      minPrice = GetMinPrice(entries),
      totalQuantity = GetQuantity(entries),
      entries = entries,
    }
    local item = Item:CreateFromItemID(GetItemInfoInstant(key))
    item:ContinueOnItemLoad(function()
      waiting = waiting - 1
      if Auctionator.Search.CheckFilters(possibleResult, self.currentFilter) then
        table.insert(results, possibleResult)
      end
      if waiting == 0 then
        completed = true
        DoComplete()
      end
    end)
  end
  if waiting == 0 and not completed then
    DoComplete()
  end
end

function AuctionatorDirectSearchProviderMixin:ProcessSearchResults(pageResults)
  Auctionator.Debug.Message("AuctionatorDirectSearchProviderMixin:ProcessSearchResults()")
  
  for _, entry in ipairs(pageResults) do

    local itemID = entry.info[Auctionator.Constants.AuctionItemInfo.ItemID]
    local itemString = Auctionator.Search.GetCleanItemLink(entry.itemLink)

    if self.resultsByKey[itemString] == nil then
      self.resultsByKey[itemString] = {}
    end

    table.insert(self.resultsByKey[itemString], entry)
    table.insert(self.individualResults, entry)
  end

  if self:HasCompleteTermResults() then
    self:AddFinalResults()
  end
end

function AuctionatorDirectSearchProviderMixin:ReceiveEvent(eventName, results, gotAllResults)
  if eventName == Auctionator.AH.Events.ScanResultsUpdate then
    self.gotAllResults = gotAllResults
    self:ProcessSearchResults(results)
  elseif eventName == Auctionator.AH.Events.ScanAborted then
    self.gotAllResults = true
    self:AddResults({})
  end
end


function AuctionatorDirectSearchProviderMixin:RegisterProviderEvents()
  if not self.registeredOnEventBus then
    self.registeredOnEventBus = true
    Auctionator.EventBus:Register(self, SEARCH_EVENTS)
  end
end

function AuctionatorDirectSearchProviderMixin:UnregisterProviderEvents()
  if not self.gotAllResults then
    Auctionator.AH.AbortQuery()
  end

  if self.registeredOnEventBus then
    self.registeredOnEventBus = false
    Auctionator.EventBus:Unregister(self, SEARCH_EVENTS)
  end
end
