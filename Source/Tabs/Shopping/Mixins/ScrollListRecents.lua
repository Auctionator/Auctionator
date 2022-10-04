AuctionatorScrollListRecentsMixin = CreateFromMixins(AuctionatorScrollListMixin)

function AuctionatorScrollListRecentsMixin:OnLoad()
  self:SetLineTemplate("AuctionatorScrollListLineRecentsTemplate")

  self:SetUpEvents()
end

function AuctionatorScrollListRecentsMixin:SetUpEvents()
  -- Auctionator Events
  Auctionator.EventBus:RegisterSource(self, "Shopping List Recents Scroll Frame")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded,
    Auctionator.Shopping.Events.RecentSearchesUpdate,
    Auctionator.Shopping.Events.OneItemSearch,
  })
end

function AuctionatorScrollListRecentsMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Events.OneItemSearch and self:IsShown() then
    self:StartSearch({ eventData }, true)
  elseif eventName == Auctionator.Shopping.Events.RecentSearchesUpdate then
    self:RefreshScrollFrame()
  elseif eventName == Auctionator.Shopping.Events.ListSearchStarted then
    self.SpinnerAnim:Play()
    self.LoadingSpinner:Show()
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.LoadingSpinner:Hide()
  end
end

function AuctionatorScrollListRecentsMixin:StartSearch(searchTerms)
  Auctionator.EventBus:Fire(
    self,
    Auctionator.Shopping.Events.SearchForTerms,
    searchTerms
  )
end

function AuctionatorScrollListRecentsMixin:GetNumEntries()
  return #Auctionator.Shopping.Recents.GetAll()
end

function AuctionatorScrollListRecentsMixin:GetEntry(index)
  return Auctionator.Shopping.Recents.GetAll()[index]
end
