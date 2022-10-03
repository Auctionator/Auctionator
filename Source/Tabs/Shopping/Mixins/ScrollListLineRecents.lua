AuctionatorScrollListLineRecentsMixin = CreateFromMixins(AuctionatorScrollListLineMixin) 

function AuctionatorScrollListLineRecentsMixin:InitLine()
  Auctionator.EventBus:RegisterSource(self, "Recents List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded,
    Auctionator.Shopping.Events.DialogOpened,
    Auctionator.Shopping.Events.DialogClosed,
  })

  self.shouldRemoveHighlight = true
end

function AuctionatorScrollListLineRecentsMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Shopping.Events.ListSearchStarted then
    if self.shouldRemoveHighlight then
      self.LastSearchedHighlight:Hide()
    end
    self:Disable()
  elseif eventName == Auctionator.Shopping.Events.ListSearchEnded then
    self.shouldRemoveHighlight = true
    self:Enable()
  elseif eventName == Auctionator.Shopping.Events.DialogOpened then
    self:Disable()
  elseif eventName == Auctionator.Shopping.Events.DialogClosed then
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
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.RecentSearchesUpdate)
  end
end

function AuctionatorScrollListLineRecentsMixin:CopyItem()
  if not self:IsEnabled() then
    return
  end

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.CopyIntoList, self.searchTerm)
end

function AuctionatorScrollListLineRecentsMixin:OnSelected()
  self.LastSearchedHighlight:Show()
  self.shouldRemoveHighlight = false
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.OneItemSearch, self.searchTerm)
end
