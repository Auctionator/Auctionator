AuctionatorScrollListLineRecentsMixin = CreateFromMixins(AuctionatorScrollListLineMixin) 

function AuctionatorScrollListLineRecentsMixin:InitLine()
  Auctionator.EventBus:RegisterSource(self, "Recents List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.DialogOpened,
    Auctionator.ShoppingLists.Events.DialogClosed,
  })
end

function AuctionatorScrollListLineRecentsMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.DialogOpened then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.DialogClosed then
    self:Enable()
  end
end

function AuctionatorScrollListLineRecentsMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  local index = tIndexOf(AUCTIONATOR_RECENT_SEARCHES, self.searchTerm)

  if index ~= nil then
    table.remove(AUCTIONATOR_RECENT_SEARCHES, index)
    Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.RecentSearchesUpdate)
  end
end

function AuctionatorScrollListLineRecentsMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.OneItemSearch, self.searchTerm)
end
