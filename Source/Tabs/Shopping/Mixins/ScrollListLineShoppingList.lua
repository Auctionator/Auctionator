AuctionatorScrollListLineShoppingListMixin = CreateFromMixins(AuctionatorScrollListLineMixin)

function AuctionatorScrollListLineShoppingListMixin:InitLine(currentList)
  Auctionator.Debug.Message("AuctionatorScrollListLineShoppingListShoppingListMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListSelected,
    Auctionator.Shopping.Events.ListSearchStarted,
    Auctionator.Shopping.Events.ListSearchEnded,
    Auctionator.Shopping.Events.DialogOpened,
    Auctionator.Shopping.Events.DialogClosed,
  })

  self.currentList = currentList
end

function AuctionatorScrollListLineShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.Shopping.Events.ListSelected then
    self.currentList = eventData
    self.LastSearchedHighlight:Hide()
  elseif eventName == Auctionator.Shopping.Events.ListSearchStarted then
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

function AuctionatorScrollListLineShoppingListMixin:GetListIndex()
  return tIndexOf(self.currentList.items, self.searchTerm)
end

function AuctionatorScrollListLineShoppingListMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  local itemIndex = self:GetListIndex()

  table.remove(self.currentList.items, itemIndex)
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListItemDeleted)
end

function AuctionatorScrollListLineShoppingListMixin:EditItem()
  if not self:IsEnabled() then
    return
  end

  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.EditListItem, self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:OnMouseDown()
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.DragItemStart, self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:OnMouseUp()
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.DragItemStop)
end

function AuctionatorScrollListLineShoppingListMixin:OnEnter()
  AuctionatorScrollListLineMixin.OnEnter(self)

  if IsMouseButtonDown("LeftButton") then
    Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.DragItemEnter, self:GetListIndex())
  end
end

function AuctionatorScrollListLineShoppingListMixin:OnClick()
  self.LastSearchedHighlight:Show()
  self.shouldRemoveHighlight = false
  Auctionator.EventBus:Fire(self, Auctionator.Shopping.Events.ListItemSelected, self.searchTerm)
end
