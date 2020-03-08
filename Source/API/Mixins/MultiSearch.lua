AuctionatorAPIMultiSearchFrame = CreateFromMixins(AuctionatorKeywordSearchProviderMixin)

function AuctionatorAPIMultiSearchFrame:OnLoad()
  self:InitSearch(
    function(results)
      self:EndSearch(results)
    end,
    function(current, total)
      self:ShowSpinner()
    end
  )
end

function AuctionatorAPIMultiSearchFrame:OnEvent(eventName, ...)
  self:OnSearchEvent(eventName, ...)
end

function AuctionatorAPIMultiSearchFrame:ShowSpinner()
  AuctionHouseFrame.BrowseResultsFrame.ItemList.LoadingSpinner:Show()
end

function AuctionatorAPIMultiSearchFrame:HideSpinner()
  AuctionHouseFrame.BrowseResultsFrame.ItemList.LoadingSpinner:Hide()
end

function AuctionatorAPIMultiSearchFrame:StartSearch(searchTerms)
  self:Search(searchTerms)
  self:ShowSpinner()
end

function AuctionatorAPIMultiSearchFrame:EndSearch(results)
  Auctionator.Search.SafeItemKeysSearch(results)
  self:HideSpinner()
end
