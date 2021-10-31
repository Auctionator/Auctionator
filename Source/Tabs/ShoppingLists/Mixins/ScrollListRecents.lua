AuctionatorScrollListRecentsMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListRecentsMixin:OnLoad()
  self:SetLineTemplate("AuctionatorScrollListLineRecentsTemplate")

  self:SetUpEvents()
end

function AuctionatorScrollListRecentsMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Recents Scroll Frame")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.RecentSearchesUpdate,
    Auctionator.ShoppingLists.Events.OneItemSearch,
  })
end

function AuctionatorScrollListRecentsMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.ShoppingLists.Events.RecentSearchesUpdate then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self.LoadingSpinner:Hide()
  end
end

function AuctionatorScrollListRecentsMixin:StartSearch(searchTerms)
  Auctionator.EventBus:Fire(
    self,
    Auctionator.ShoppingLists.Events.SearchForTerms,
    searchTerms
  )
end

function AuctionatorScrollListRecentsMixin:GetNumEntries()
  return #AUCTIONATOR_RECENT_SEARCHES
end

function AuctionatorScrollListRecentsMixin:GetEntry(index)
  return AUCTIONATOR_RECENT_SEARCHES[index]
end
