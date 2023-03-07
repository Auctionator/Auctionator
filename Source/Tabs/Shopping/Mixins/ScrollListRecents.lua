AuctionatorScrollListRecentsMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListRecentsMixin:OnLoad()
  self:SetLineTemplate("AuctionatorScrollListLineRecentsTemplate")

  self:SetUpEvents()
end

function AuctionatorScrollListRecentsMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Recents Scroll Frame")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
    Auctionator.Shopping.Tab.Events.RecentSearchesUpdate,
    Auctionator.Shopping.Tab.Events.OneItemSearch,
  })
end

function AuctionatorScrollListRecentsMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Tab.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.Shopping.Tab.Events.RecentSearchesUpdate then
    self:RefreshScrollFrame(true)
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    self.LoadingSpinner:Hide()
  end
end

function AuctionatorScrollListRecentsMixin:StartSearch(searchTerms)
  Auctionator.EventBus:Fire(
    self,
    Auctionator.Shopping.Tab.Events.SearchForTerms,
    searchTerms
  )
end

function AuctionatorScrollListRecentsMixin:GetNumEntries()
  return #Auctionator.Shopping.Recents.GetAll()
end

function AuctionatorScrollListRecentsMixin:GetEntry(index)
  return Auctionator.Shopping.Recents.GetAll()[index]
end
