AuctionatorSearchProviderMixin = {}

-- Derive
function AuctionatorSearchProviderMixin:OnSearchEventReceived(eventName, ...)
end

-- Derive
function AuctionatorSearchProviderMixin:CreateSearchTerm(term)
end

-- Derive
function AuctionatorSearchProviderMixin:GetSearchProvider()
end

-- Derive
function AuctionatorSearchProviderMixin:RegisterProviderEvents()
end

-- Derive
function AuctionatorSearchProviderMixin:UnregisterProviderEvents()
end

-- Derive
function AuctionatorSearchProviderMixin:HasCompleteTermResults()
end

function AuctionatorSearchProviderMixin:RegisterEvents(events)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:RegisterEvents()", events)

  FrameUtil.RegisterFrameForEvents(self, events)
end

function AuctionatorSearchProviderMixin:UnregisterEvents(events)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:UnregisterEvents()", events)

  FrameUtil.UnregisterFrameForEvents(self, events)
end

function AuctionatorSearchProviderMixin:SetTerms(terms)
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:SetTerms()", terms)

  self.terms = terms
  self.index = 1
end

function AuctionatorSearchProviderMixin:GetCurrentSearchIndex()
  return self.index
end

function AuctionatorSearchProviderMixin:GetSearchTermCount()
  return #self.terms
end

function AuctionatorSearchProviderMixin:HasMoreTerms()
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:HasMoreTerms()")

  return
    self.terms ~= nil and
    #self.terms > 0 and
    self.index ~= nil and
    self.index <= #self.terms
end

function AuctionatorSearchProviderMixin:GetNextSearchParameter()
  Auctionator.Debug.Message("AuctionatorSearchProviderMixin:GetNextSearchParameter()")

  if self:HasMoreTerms() then
    self.index = self.index + 1

    return self:CreateSearchTerm(self.terms[self.index - 1])
  else
    error("You requested a term that does not exist: " .. (self.index == nil and "nil" or self.index))
  end
end
