AuctionatorKeywordSearchProviderMixin = CreateFromMixins(AuctionatorMultiSearchMixin, AuctionatorSearchProviderMixin)

local KEYWORD_SEARCH_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_FAILURE"
}

function AuctionatorKeywordSearchProviderMixin:CreateSearchTerm(term)
  Auctionator.Debug.Message("AuctionatorKeywordSearchProviderMixin:CreateSearchTerm()", term)

  return  {
    searchString = term,
    filters = {},
    itemClassFilters = {},
    sorts = {}
  }
end

function AuctionatorKeywordSearchProviderMixin:GetSearchProvider()
  Auctionator.Debug.Message("AuctionatorKeywordSearchProviderMixin:GetSearchProvider()")

  return C_AuctionHouse.SendBrowseQuery
end

function AuctionatorKeywordSearchProviderMixin:HasCompleteTermResults()
  Auctionator.Debug.Message("AuctionatorKeywordSearchProviderMixin:HasCompleteTermResults()")
  return C_AuctionHouse.HasFullBrowseResults()
end

function AuctionatorKeywordSearchProviderMixin:OnSearchEventReceived(eventName, ...)
  Auctionator.Debug.Message("AuctionatorKeywordSearchProviderMixin:OnSearchEventReceived()", eventName, ...)

  if eventName == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self:ProcessSearchResults(C_AuctionHouse.GetBrowseResults())
  elseif eventName == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:ProcessSearchResults(...)
  elseif eventName == "AUCTION_HOUSE_BROWSE_FAILURE" then
    AuctionHouseFrame.BrowseResultsFrame.ItemList:SetCustomError(
      RED_FONT_COLOR:WrapTextInColorCode(ERR_AUCTION_DATABASE_ERROR)
    )
  end
end

function AuctionatorKeywordSearchProviderMixin:ProcessSearchResults(addedResults)
  Auctionator.Debug.Message("AuctionatorKeywordSearchProviderMixin:ProcessSearchResults()")

  self:AddResults(addedResults)
end

function AuctionatorKeywordSearchProviderMixin:RegisterProviderEvents()
  self:RegisterEvents(KEYWORD_SEARCH_EVENTS)
end

function AuctionatorKeywordSearchProviderMixin:UnregisterProviderEvents()
  self:UnregisterEvents(KEYWORD_SEARCH_EVENTS)
end
