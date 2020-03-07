AuctionatorScrollListLineMixin = CreateFromMixins(ScrollListLineMixin, TableBuilderRowMixin, AuctionatorEventBus, AuctionatorAdvancedSearchProviderMixin)

function AuctionatorScrollListLineMixin:OnLoad()
  self:Register(self, { Auctionator.ShoppingLists.Events.DeleteFromList })
  self:InitSearch(
    function(results)
      self:EndSearch(results)
    end
  )
end

function AuctionatorScrollListLineMixin:OnEvent(eventName, ...)
  self:OnSearchEvent(eventName, ...)
end

function AuctionatorScrollListLineMixin:InitLine(scrollFrame)
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()", scrollFrame)

  scrollFrame:Register(self, {
    Auctionator.ShoppingLists.Events.ListItemDeleted,
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
  self.scrollFrameParent = scrollFrame
end

function AuctionatorScrollListLineMixin:EventUpdate(eventName, eventData)
  if eventName == Auctionator.ShoppingLists.Events.ListSelected then
    self.currentList = eventData
  elseif eventName == Auctionator.ShoppingLists.Events.DeleteFromList then
    self:DeleteItem()
    self.scrollFrameParent:Fire(Auctionator.ShoppingLists.Events.ListItemDeleted)
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
end

function AuctionatorScrollListLineMixin:UpdateDisplay()
  self.Text:SetText(Auctionator.Search.PrettifySearchString(self.searchTerm))
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

function AuctionatorScrollListLineMixin:OnSelected()
  self:Search({self.searchTerm})
end

function AuctionatorScrollListLineMixin:EndSearch(results)
  Auctionator.Search.SafeItemKeysSearch(results)
end

AuctionatorScrollListLineDeleteMixin = {}

function AuctionatorScrollListLineDeleteMixin:OnClick()
  self:GetParent():Fire(Auctionator.ShoppingLists.Events.DeleteFromList)
end
