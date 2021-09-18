AuctionatorScrollListRecentsMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListRecentsMixin:OnLoad()
  self:SetLineTemplate("AuctionatorScrollListLineRecentsTemplate")
  self.searchProvider = CreateFrame("FRAME", nil, nil, "AuctionatorDirectSearchProviderTemplate")
  self.searchProvider:InitSearch(
    function(results)
      self.LoadingSpinner:Hide()
      Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchEnded, results)
    end,
    function(current, total, partialResults)
      Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate, partialResults)
    end
  )

  self:SetUpEvents()
end

function AuctionatorScrollListRecentsMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Recents Scroll Frame")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.OneItemSearch,
    Auctionator.ShoppingLists.Events.NewRecentSearch,
  })
end

function AuctionatorScrollListRecentsMixin:OnHide()
  self.searchProvider:AbortSearch()
end

function AuctionatorScrollListRecentsMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.ShoppingLists.Events.NewRecentSearch then
    self:RefreshScrollFrame()
  end
end

function AuctionatorScrollListRecentsMixin:StartSearch(searchTerms)
  self.searchProvider:AbortSearch()

  self.SpinnerAnim:Play()
  self.LoadingSpinner:Show()

  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.ListSearchStarted
  )
  self.searchProvider:Search(searchTerms)
end

function AuctionatorScrollListRecentsMixin:GetNumEntries()
  return #AUCTIONATOR_RECENT_SEARCHES
end

function AuctionatorScrollListRecentsMixin:GetEntry(index)
  return AUCTIONATOR_RECENT_SEARCHES[index]
end
