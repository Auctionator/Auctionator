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
  self.partialResults = {}
  self.fullResults = {}

  self:RegisterProviderEvents()

  self:SetTerms(terms)
  self:InitializeNewSearchGroup()
end

function AuctionatorMultiSearchMixin:AbortSearch()
  self:UnregisterProviderEvents()
  local isComplete = self.complete
  self.complete = true
  if not isComplete then
    self.onSearchComplete(self.partialResults)
  end
end

function AuctionatorMultiSearchMixin:SearchGroupReady()
  self:NextSearch()
end

function AuctionatorMultiSearchMixin:AddResults(results)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:AddResults()")

  for index = 1, #results do
    table.insert(self.partialResults, results[index])
    table.insert(self.fullResults, results[index])
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
      self.partialResults
    )
    self.partialResults = {}
    self:GetSearchProvider()(self:GetNextSearchParameter())
  else
    Auctionator.Debug.Message("AuctionatorMultiSearchMixin:NextSearch Complete")

    self.complete = true
    self:UnregisterProviderEvents()
    self.onSearchComplete(self.fullResults)
  end
end
