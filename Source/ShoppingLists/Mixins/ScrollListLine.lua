AuctionatorScrollListLineMixin = CreateFromMixins(
  ScrollListLineMixin,
  TableBuilderRowMixin
)

function AuctionatorScrollListLineMixin:InitLine()
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()")

  Auctionator.EventBus:RegisterSource(self, "Shopping List Line Item")

  Auctionator.EventBus:Register(self, {
    Auctionator.ShoppingLists.Events.ListSelected,
    Auctionator.ShoppingLists.Events.ListSearchStarted,
    Auctionator.ShoppingLists.Events.ListSearchEnded
  })
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

local function ComposeTooltip(searchTerm)
  local tooltipDetails = Auctionator.Search.ComposeTooltip(searchTerm)

  GameTooltip:SetText(tooltipDetails.title, 1, 1, 1, 1)

  for _, line in ipairs(tooltipDetails.lines) do
    if line[2] == AUCTIONATOR_L_ANY_LOWER then
      -- Faded line when no filter set
      GameTooltip:AddDoubleLine(line[1], line[2], 0.4, 0.4, 0.4, 0.4, 0.4, 0.4)

    else
      GameTooltip:AddDoubleLine(
        line[1],
        WHITE_FONT_COLOR:WrapTextInColorCode(line[2])
      )
    end
  end
end

function AuctionatorScrollListLineMixin:OnEnter()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  ComposeTooltip(self.searchTerm)
  GameTooltip:Show()
end

function AuctionatorScrollListLineMixin:OnLeave()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  GameTooltip:Hide()
end

function AuctionatorScrollListLineMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemSelected, self.searchTerm)
end
