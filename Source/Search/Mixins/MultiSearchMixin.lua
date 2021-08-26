AuctionatorMultiSearchMixin = {}

function AuctionatorMultiSearchMixin:InitSearch(completionCallback, incrementCallback)
  Auctionator.Debug.Message("AuctionatorMultiSearchMixin:InitSearch()")

  self.complete = true
  self.onSearchComplete = completionCallback or function()
    Auctionator.Debug.Message("Search completed.")
  end
  self.onNextSearch = incrementCallback or function()
    Auctionator.Debug.Message("Next search.")
  end
end

function AuctionatorMultiSearchMixin:OnEvent(event, ...)
  self:OnSearchEventReceived(event, ...)
end

function AuctionatorMultiSearchMixin:Search(terms)
  Auctionator.Debug.Message("AuctionatorMultiSearchMixin:Search()", terms)

  self.complete = false
  self.results = {}

  self:RegisterProviderEvents()

  self:SetTerms(terms)
  self:InitializeNewSearchGroup()
end

function AuctionatorMultiSearchMixin:AbortSearch()
  self:UnregisterProviderEvents()
  local isComplete = self.complete
  self.complete = true
  if not isComplete then
    self.onSearchComplete(self.results)
  end
end

function AuctionatorMultiSearchMixin:SearchGroupReady()
  self:NextSearch()
end

function AuctionatorMultiSearchMixin:AddResults(results)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:AddResults()")

  for index = 1, #results do
    table.insert(self.results, results[index])
  end

  if self:HasCompleteTermResults() then
    self:NextSearch()
  end
end

function AuctionatorMultiSearchMixin:NextSearch()
  if self:HasMoreTerms() then
    self.onNextSearch(
      self:GetCurrentSearchIndex(),
      self:GetSearchTermCount(),
      self.results
    )
    self:GetSearchProvider()(self:GetNextSearchParameter())
  else
    Auctionator.Debug.Message("AuctionatorMultiSearchMixin:NextSearch Complete")

    self.complete = true
    self:UnregisterProviderEvents()
    self.onSearchComplete(self.results)
  end
end
