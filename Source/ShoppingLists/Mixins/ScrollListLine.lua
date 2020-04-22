AuctionatorScrollListLineMixin = CreateFromMixins(
  ScrollListLineMixin,
  TableBuilderRowMixin
)

function AuctionatorScrollListLineMixin:InitLine(scrollFrame)
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })

  self.scrollFrameParent = scrollFrame
end

function AuctionatorScrollListLineMixin:ReceiveEvent(eventName, eventData, ...)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchStarted then
    self:Disable()
  elseif eventName == Auctionator.ShoppingLists.Events.ListSearchEnded then
    self:Enable()
  end
end

function AuctionatorScrollListLineMixin:DeleteItem()
  local itemIndex = 0

  for index, name in ipairs(self.currentList.items) do
    if self.searchTerm == name then
      itemIndex = index
      break
    end
  end

  table.remove(self.currentList.items, itemIndex)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemDeleted)
end

function AuctionatorScrollListLineMixin:UpdateDisplay()
  self.Text:SetText(Auctionator.Search.PrettifySearchString(self.searchTerm))
end

function AuctionatorScrollListLineMixin:Populate(searchTerm, dataIndex)
  self.searchTerm = searchTerm
  self.dataIndex = dataIndex
end

function AuctionatorScrollListLineMixin:OnEnter()
  -- Have to override since we arent building rows (see TableBuilder.lua)
end

function AuctionatorScrollListLineMixin:OnLeave()
  -- Have to override since we arent building rows (see TableBuilder.lua)
end

function AuctionatorScrollListLineMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemSelected, self.searchTerm)
end
