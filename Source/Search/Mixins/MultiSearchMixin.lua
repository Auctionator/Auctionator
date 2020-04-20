AuctionatorMultiSearchMixin = {}

function AuctionatorMultiSearchMixin:InitSearch(completionCallback, incrementCallback)
  Auctionator.Debug.Message("AuctionatorMultiSearchMixin:InitSearch()")

  self:RegisterProviderEvents()

  self.complete = true
  self.onSearchComplete = completionCallback or function()
    Auctionator.Debug.Message("Search completed.")
  end
  self.onNextSearch = incrementCallback or function()
    Auctionator.Debug.Message("Next search.")
  end
end

function AuctionatorMultiSearchMixin:OnSearchEvent(event, ...)
  if not self.complete then
    self:OnSearchEventReceived(event, ...)
  end
end

function AuctionatorMultiSearchMixin:Search(terms)
  Auctionator.Debug.Message("AuctionatorMultiSearchMixin:Search()", terms)

  self.complete = false
  self.results = {}

  self:SetTerms(terms)
  self:NextSearch()
end

function AuctionatorMultiSearchMixin:AddResults(results)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:AddResults()")

  for index = 0, #results do
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
    self.onSearchComplete(self.results)
  end
end
