AuctionatorScrollListLineMixin = CreateFromMixins(ScrollListLineMixin, TableBuilderRowMixin, AuctionatorEventBus)

function AuctionatorScrollListLineMixin:OnLoad()
  self:Register(self, { Auctionator.ShoppingLists.Events.DeleteFromList })
end

function AuctionatorScrollListLineMixin:InitLine(scrollFrame)
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()", scrollFrame)

  scrollFrame:Register(self, { Auctionator.ShoppingLists.Events.ListItemDeleted, Auctionator.ShoppingLists.Events.ListSelected})
  self.scrollFrameParent = scrollFrame
end

function AuctionatorScrollListLineMixin:EventUpdate(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
  elseif eventName == Auctionator.ShoppingLists.Events.DeleteFromList then
    self:DeleteItem()
    self.scrollFrameParent:Fire(Auctionator.ShoppingLists.Events.ListItemDeleted)
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
end

function AuctionatorScrollListLineMixin:UpdateDisplay()
  self.Text:SetText(self.searchTerm)
end

function AuctionatorScrollListLineMixin:OnSelected()
  local query = {}

  query.searchString = self.searchTerm
  query.minLevel = 0
  query.maxLevel = 1000
  query.filters = {}
  query.itemClassFilters = {}
  query.sorts = {}

  C_AuctionHouse.SendBrowseQuery(query)
end

function AuctionatorScrollListLineMixin:Populate(searchTerm, dataIndex)
  self.searchTerm = searchTerm
  self.dataIndex = dataIndex
end

function AuctionatorScrollListLineMixin:OnDeleteClicked(self)
  Auctionator.Debug.Message("OnDeleteClicked", self.searchTerm)
end

-- Have to override since we arent building rows (see TableBuilder.lua)
function AuctionatorScrollListLineMixin:OnEnter()
  -- Auctionator.Debug.Message("AuctionatorScrollListLineMixin:OnEnter()")
end

function AuctionatorScrollListLineMixin:OnLeave()
  -- Auctionator.Debug.Message("AuctionatorScrollListLineMixin:OnLeave()")
end

AuctionatorScrollListLineDeleteMixin = {}

function AuctionatorScrollListLineDeleteMixin:OnClick()
  self:GetParent():Fire(Auctionator.ShoppingLists.Events.DeleteFromList)
end