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
end

function AuctionatorScrollListLineRecentsMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.OneItemSearch, self.searchTerm)
end
