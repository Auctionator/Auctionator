AuctionatorScrollListLineShoppingListMixin = CreateFromMixins(AuctionatorScrollListLineMixin)

function AuctionatorScrollListLineShoppingListMixin:InitLine(currentList)
  Auctionator.Debug.Message("AuctionatorScrollListLineShoppingListShoppingListMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded,
    Auctionator.ShoppingLists.Events.DialogOpened,
    Auctionator.ShoppingLists.Events.DialogClosed,
  })

  self.currentList = currentList
end

function AuctionatorScrollListLineShoppingListMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  elseif eventName == Auctionator.ShoppingLists.Events.DialogOpened then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.DialogClosed then
    self:Enable()
  end
end

function AuctionatorScrollListLineShoppingListMixin:GetListIndex()
  for index, name in ipairs(self.currentList.items) do
    if self.searchTerm == name then
      return index
    end
  end
end

function AuctionatorScrollListLineShoppingListMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  local itemIndex = self:GetListIndex()

  table.remove(self.currentList.items, itemIndex)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemDeleted)
end

function AuctionatorScrollListLineShoppingListMixin:EditItem()
  if not self:IsEnabled() then
    return
  end

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.EditListItem, self:GetListIndex())
end

function AuctionatorScrollListLineShoppingListMixin:ShiftItem(amount)
  local index = self:GetListIndex()
  local otherItem = self.currentList.items[index + amount]
  if otherItem ~= nil then
    self.currentList.items[index] = otherItem
    self.currentList.items[index + amount] = self.searchTerm
  end
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListOrderChanged)
end

function AuctionatorScrollListLineShoppingListMixin:DetectDragStart()
  --If the mouse leaves above this point, its been dragged up, and if dragged
  --down, it has been dragged below this point
  self.dragStartY = select(2, GetCursorPosition())
end

function AuctionatorScrollListLineShoppingListMixin:DetectDragEnd()
  if IsMouseButtonDown("LeftButton") then
    local y = select(2, GetCursorPosition())
    if y > self.dragStartY then
      self:ShiftItem(-1)
    elseif y < self.dragStartY then
      self:ShiftItem(1)
    end
  end
end

function AuctionatorScrollListLineShoppingListMixin:OnEnter()
  AuctionatorScrollListLineMixin.OnEnter(self)

  self:DetectDragStart()
end

function AuctionatorScrollListLineShoppingListMixin:OnLeave()
  AuctionatorScrollListLineMixin.OnLeave(self)
  self:DetectDragEnd()
end

function AuctionatorScrollListLineShoppingListMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemSelected, self.searchTerm)
end
