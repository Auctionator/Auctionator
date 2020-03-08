AuctionatorAPIv1MultiSearchFrame = CreateFromMixins(AuctionatorKeywordSearchProviderMixin)

function AuctionatorAPIv1MultiSearchFrame:OnLoad()
  self:InitSearch(
    function(results)
      self:EndSearch(results)
    end,
    function(current, total)
      self:ShowSpinner()
    end
  )
end

function AuctionatorAPIv1MultiSearchFrame:OnEvent(eventName, ...)
  self:OnSearchEvent(eventName, ...)
end

function AuctionatorAPIv1MultiSearchFrame:ShowSpinner()
  AuctionHouseFrame.BrowseResultsFrame.ItemList.LoadingSpinner:Show()
end

function AuctionatorAPIv1MultiSearchFrame:HideSpinner()
  AuctionHouseFrame.BrowseResultsFrame.ItemList.LoadingSpinner:Hide()
end

function AuctionatorAPIv1MultiSearchFrame:StartSearch(searchTerms)
  self:Search(searchTerms)
  self:ShowSpinner()
end

function AuctionatorAPIv1MultiSearchFrame:EndSearch(results)
  Auctionator.Search.SafeItemKeysSearch(results)
  self:HideSpinner()
end
