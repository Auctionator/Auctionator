AuctionatorScrollListLineMixin = CreateFromMixins(ScrollListLineMixin, TableBuilderRowMixin, AuctionatorAdvancedSearchProviderMixin)

function AuctionatorScrollListLineMixin:OnLoad()
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
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })

  self.scrollFrameParent = scrollFrame
end

function AuctionatorScrollListLineMixin:ReceiveEvent(eventName, eventData)
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
  self.scrollFrameParent:GetParent():Fire(Auctionator.ShoppingLists.Events.ListSearchIncrementalUpdate, results)
end

AuctionatorScrollListLineDeleteMixin = {}

function AuctionatorScrollListLineDeleteMixin:OnLoad()
  Auctionator.EventBus:RegisterSource(self, "Shopping Item Delete Button")
end

function AuctionatorScrollListLineDeleteMixin:OnClick()
  self:GetParent():DeleteItem()
end
