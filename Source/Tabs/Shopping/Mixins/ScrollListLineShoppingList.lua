AuctionatorScrollListLineShoppingListMixin = CreateFromMixins(AuctionatorScrollListLineMixin)

function AuctionatorScrollListLineShoppingListMixin:InitLine(currentList)
  Auctionator.Debug.Message("AuctionatorScrollListLineShoppingListShoppingListMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Tab.Events.ListSelected,
    Auctionator.Shopping.Tab.Events.ListSearchStarted,
    Auctionator.Shopping.Tab.Events.ListSearchEnded,
    Auctionator.Shopping.Tab.Events.DialogOpened,
    Auctionator.Shopping.Tab.Events.DialogClosed,
  })

  self.currentList = currentList
end

function AuctionatorScrollListLineShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Shopping.Tab.Events.ListSelected then
    self.currentList = eventData
    self.LastSearchedHighlight:Hide()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchStarted then
    if self.shouldRemoveHighlight then
      self.LastSearchedHighlight:Hide()
    end
    self:Disable()
  elseif eventName == Auctionator.Shopping.Tab.Events.ListSearchEnded then
    self.shouldRemoveHighlight = true
    self:Enable()
  elseif eventName == Auctionator.Shopping.Tab.Events.DialogOpened then
    self:Disable()
  elseif eventName == Auctionator.Shopping.Tab.Events.DialogClosed then
    self:Enable()
  end
end

function AuctionatorScrollListLineShoppingListMixin:GetListIndex()
  return self.currentList:GetIndexForItem(self.searchTerm)
end

function AuctionatorScrollListLineShoppingListMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  self.currentList:DeleteItem(self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:EditItem()
  if not self:IsEnabled() then
    return
  end

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.EditListItem, self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:OnMouseDown()
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.DragItemStart, self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:OnMouseUp()
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.DragItemStop)
end

function AuctionatorScrollListLineShoppingListMixin:OnEnter()
  AuctionatorScrollListLineMixin.OnEnter(self)

  if IsMouseButtonDown("LeftButton") then
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.DragItemEnter, self:GetListIndex())
  end
end

function AuctionatorScrollListLineShoppingListMixin:OnClick()
  self.LastSearchedHighlight:Show()
  self.shouldRemoveHighlight = false
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Tab.Events.ListItemSelected, self.searchTerm)
end
