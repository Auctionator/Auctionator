AuctionatorScrollListLineMixin = CreateFromMixins(
  ScrollListLineMixin,
  TableBuilderRowMixin
)

function AuctionatorScrollListLineMixin:InitLine(currentList)
  Auctionator.Debug.Message("AuctionatorScrollListLineMixin:InitLine()")

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

function AuctionatorScrollListLineMixin:ReceiveEvent(eventName, eventData, ...)
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

function AuctionatorScrollListLineMixin:GetListIndex()
  for index, name in ipairs(self.currentList.items) do
    if self.searchTerm == name then
      return index
    end
  end
end

function AuctionatorScrollListLineMixin:DeleteItem()
  if not self:IsEnabled() then
    return
  end

  local itemIndex = self:GetListIndex()

  table.remove(self.currentList.items, itemIndex)
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemDeleted)
end

function AuctionatorScrollListLineMixin:EditItem()
  if not self:IsEnabled() then
    return
  end

  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.EditListItem, self:GetListIndex())
end

function AuctionatorScrollListLineMixin:ShiftItem(amount)
  local index = self:GetListIndex()
  local otherItem = self.currentList.items[index + amount]
  if otherItem ~= nil then
    self.currentList.items[index] = otherItem
    self.currentList.items[index + amount] = self.searchTerm
  end
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListOrderChanged)
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

function AuctionatorScrollListLineMixin:ShowTooltip()
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  ComposeTooltip(self.searchTerm)
  GameTooltip:Show()
end

function AuctionatorScrollListLineMixin:HideTooltip()
  GameTooltip:Hide()
end

function AuctionatorScrollListLineMixin:DetectDragStart()
  --If the mouse leaves above this point, its been dragged up, and if dragged
  --down, it has been dragged below this point
  self.dragStartY = select(2, GetCursorPosition())
end

function AuctionatorScrollListLineMixin:DetectDragEnd()
  if IsMouseButtonDown("LeftButton") then
    local y = select(2, GetCursorPosition())
    if y > self.dragStartY then
      self:ShiftItem(-1)
    elseif y < self.dragStartY then
      self:ShiftItem(1)
    end
  end
end

function AuctionatorScrollListLineMixin:OnEnter()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:ShowTooltip()

  self:DetectDragStart()
end

function AuctionatorScrollListLineMixin:OnLeave()
  -- Have to override since we arent building rows (see TableBuilder.lua)

  -- Our stuff
  self:HideTooltip()

  self:DetectDragEnd()
end

function AuctionatorScrollListLineMixin:OnSelected()
  Auctionator.EventBus:Fire(self, Auctionator.ShoppingLists.Events.ListItemSelected, self.searchTerm)
end
