-- Shows all Auctionator shopping lists and their search terms, and includes
-- buttons to register a callback to (for example) do search, edit and delete
-- commands
AuctionatorShoppingTabListsContainerMixin = {}

RowType = {
  List = "list header",
  SearchTerm = "list entry",
  Empty = "list empty",
}

local listHeaderInset = 10
local listEntryInset = 30
local buttonSpacing = 60
local buttonHeight = 20
local draggingTermAlpha = 0.5

-- Callbacks to add wanted behaviour, e.g. editing a list or searching for a
-- search term
-- When a list is expanded to show its search terms
function AuctionatorShoppingTabListsContainerMixin:SetOnListExpanded(func)
  self.onListExpanded = func
end

-- When a list is collapsed by an explicit button press to hide its search terms
function AuctionatorShoppingTabListsContainerMixin:SetOnListCollapsed(func)
  self.onListCollapsed = func
end

-- When the search button is clicked on a particular list
function AuctionatorShoppingTabListsContainerMixin:SetOnListSearch(func)
  self.onListSearch = func
end

-- When the edit button is clicked on a particular list
function AuctionatorShoppingTabListsContainerMixin:SetOnListEdit(func)
  self.onListEdit = func
end

-- When the delete button is clicked on a particular list
function AuctionatorShoppingTabListsContainerMixin:SetOnListDelete(func)
  self.onListDelete = func
end

-- When the edit button is clicked on a particular search term in a list
function AuctionatorShoppingTabListsContainerMixin:SetOnSearchTermEdit(func)
  self.onSearchTermEdit = func
end

-- When the delete button is clicked on a particular search term in a list
function AuctionatorShoppingTabListsContainerMixin:SetOnSearchTermDelete(func)
  self.onSearchTermDelete = func
end

-- When the search term is just clicked
function AuctionatorShoppingTabListsContainerMixin:SetOnSearchTermClicked(func)
  self.onSearchTermClicked = func
end

-- When a search term is dragged to a different position
function AuctionatorShoppingTabListsContainerMixin:SetOnListItemDrag(func)
  self.onListItemDrag = func
end

function AuctionatorShoppingTabListsContainerMixin:ExpandList(list)
  if self.expandedList then
    self.expandedList = nil
    if self.onListCollapsed then
      self.onListCollapsed()
    end
  end
  self.expandedList = list
  self:Populate()
  self:ScrollToList(list)
  if self.onListExpanded then
    self.onListExpanded()
  end
end

function AuctionatorShoppingTabListsContainerMixin:CollapseList(list)
  self.expandedList = nil
  self:Populate()
  if list ~= nil then
    self:ScrollToList(list)
  end
  if self.onListCollapsed then
    self.onListCollapsed()
  end
end

function AuctionatorShoppingTabListsContainerMixin:TemporarilySelectSearchTerm(index)
  self.ScrollBox:ForEachFrame(function(frame)
    if frame.elementData.type == RowType.SearchTerm then
      frame.Selected:SetShown(frame.elementData.index == index)
    end
  end)
end

function AuctionatorShoppingTabListsContainerMixin:ScrollToList(list)
  local dataIndex = self.ScrollBox:FindElementDataIndexByPredicate(function(elementData)
    return elementData.type == RowType.List and elementData.list:GetName() == list:GetName()
  end)
  local scrollOffset = self.ScrollBox:GetDerivedScrollOffset()
  local dataIndexExtent = (self.ScrollBox:GetExtentUntil(dataIndex) - scrollOffset) / self.ScrollBox:GetVisibleExtent()
  if dataIndexExtent > 0.5 then
    self.ScrollBox:ScrollToElementDataIndex(dataIndex, 0.5)
  else
    self.ScrollBox:ScrollToNearest(dataIndex)
  end
end

function AuctionatorShoppingTabListsContainerMixin:ScrollToListEnd()
  if not self.expandedList then
    return
  end
  local listLength = self.expandedList:GetItemCount()
  local dataIndex = self.ScrollBox:FindElementDataIndexByPredicate(function(elementData)
    return elementData.type == RowType.SearchTerm and elementData.index == listLength
  end)
  self.ScrollBox:ScrollToNearest(dataIndex)
end

function AuctionatorShoppingTabListsContainerMixin:IsListExpanded(list)
  return self.expandedList and self.expandedList:GetName() == list:GetName()
end

function AuctionatorShoppingTabListsContainerMixin:GetExpandedList()
  return self.expandedList
end

function AuctionatorShoppingTabListsContainerMixin:OnLoad()
  self:SetupContent()

  if self:IsVisible() then
    self:Populate()
  end
end

function AuctionatorShoppingTabListsContainerMixin:OnShow()
  self:Populate()

  -- Listen to events to make sure the lists view is up to date
  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.ListMetaChange,
    Auctionator.Shopping.Events.ListItemChange,
  })
end

function AuctionatorShoppingTabListsContainerMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Shopping.Events.ListMetaChange,
    Auctionator.Shopping.Events.ListItemChange,
  })
end

function AuctionatorShoppingTabListsContainerMixin:OnDragUpdate()
  if not self:IsMouseOver() or not IsMouseButtonDown("LeftButton") then
    self.ScrollBox:ForEachFrame(function(frame)
      if frame.elementData.type == RowType.SearchTerm and frame.elementData.index == self.draggingIndex then
        frame:SetAlpha(1)
      end
    end)
    self.draggingIndex = nil
    self:SetScript("OnUpdate", nil)
  elseif self.dragTargetIndex ~= nil then
    local oldIndex = self.draggingIndex
    local newIndex = self.dragTargetIndex
    self.draggingIndex = self.dragTargetIndex
    self.dragTargetIndex = nil
    if self.onListItemDrag and oldIndex ~= newIndex then
      self.onListItemDrag(self.expandedList, oldIndex, newIndex)
    end
  end
end

function AuctionatorShoppingTabListsContainerMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Events.ListItemChange then
    if self.expandedList and self.expandedList:GetName() == eventData then
      self:Populate()
    end
  elseif eventName == Auctionator.Shopping.Events.ListMetaChange then
    self:Populate()
  end
end

function AuctionatorShoppingTabListsContainerMixin:SetupContent()
  local function OnClick(button, buttonClickedString)
    if buttonClickedString == "RightButton" then
      if self.expandedList then
        self:CollapseList(self.expandedList)
      end
    else
      if button.elementData.type == RowType.List then
        if self:IsListExpanded(button.elementData.list) then
          self:CollapseList(button.elementData.list)
        else
          self:ExpandList(button.elementData.list)
        end
      elseif button.elementData.type == RowType.SearchTerm then
        if self.onSearchTermClicked and self.expandedList then
          self.onSearchTermClicked(self.expandedList, button.elementData.searchTerm, button.elementData.index)
        end
      end
    end
  end

  local function OnEnter(button)
    button.Highlight:Show()
    if button.elementData and button.elementData.type == RowType.SearchTerm then
      GameTooltip:SetOwner(button, "ANCHOR_NONE")
      Auctionator.Shopping.Tab.ComposeSearchTermTooltip(button.elementData.searchTerm)
      GameTooltip:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT")
      GameTooltip:Show()
      if self.draggingIndex ~= nil then
        self.dragTargetIndex = button.elementData.index
      end
    end
  end

  local function OnLeave(button)
    button.Highlight:Hide()
    if button.elementData and button.elementData.type == RowType.SearchTerm then
      GameTooltip:Hide()
    end
  end

  local function OnMouseDown(button, buttonClickedString)
    if buttonClickedString == "LeftButton" and button.elementData and button.elementData.type == RowType.SearchTerm then
      self.dragTargetIndex = nil
      self.draggingIndex = button.elementData.index
      button:SetAlpha(draggingTermAlpha)
      self:SetScript("OnUpdate", self.OnDragUpdate)
    end
  end

  local function OnListSearchOptionClicked(button)
    button = button:GetParent()
    if self.onListSearch then
      self.onListSearch(button.elementData.list)
    end
  end

  local function OnListEditOptionClicked(button)
    button = button:GetParent()
    if self.onListEdit then
      self.onListEdit(button.elementData.list)
    end
  end

  local function OnListDeleteOptionClicked(button)
    button = button:GetParent()
    self.onListDelete(button.elementData.list)
  end

  local function OnSearchTermDeleteOptionClicked(button)
    button = button:GetParent()
    if self.onSearchTermDelete then
      self.onSearchTermDelete(self.expandedList, button.elementData.searchTerm, button.elementData.index)
    end
  end

  local function OnSearchTermEditOptionClicked(button)
    button = button:GetParent()
    if self.onSearchTermEdit then
      self.onSearchTermEdit(self.expandedList, button.elementData.searchTerm, button.elementData.index)
    end
  end

  local function CreateOptionButton(button, xOffset, xWidth)
    local option = CreateFrame("Button", nil, button)
    option:SetPoint("TOPRIGHT", xOffset, 0)
    option:SetSize(xWidth, buttonHeight)
    option.Icon = option:CreateTexture()
    option.Icon:SetSize(buttonHeight - 5, buttonHeight - 5)
    option.Icon:SetPoint("CENTER")
    option:SetScript("OnEnter", function()
      option.Icon:SetAlpha(0.5)
      if option.TooltipText then
        GameTooltip:SetOwner(option, "ANCHOR_RIGHT")
        GameTooltip:SetText(option.TooltipText, 1, 1, 1)
        GameTooltip:Show()
      end
    end)
    option:SetScript("OnLeave", function()
      option.Icon:SetAlpha(1)
      if option.TooltipText then
        GameTooltip:Hide()
      end
    end)
    option:SetScript("OnHide", function()
      option.Icon:SetAlpha(1)
    end)
    return option
  end

  local function SetupButton(button)
    button.setup = true
    Auctionator.Shopping.Tab.SetupContainerRow(button, buttonHeight, buttonSpacing)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:SetScript("OnClick", OnClick)
    button:SetScript("OnMouseDown", OnMouseDown)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    button.options1 = Auctionator.Shopping.Tab.CreateOptionButton(button, 0, buttonHeight + 5, buttonHeight)
    button.options2 = Auctionator.Shopping.Tab.CreateOptionButton(button, -buttonHeight - 5, buttonHeight + 5, buttonHeight)
    button.options3 = Auctionator.Shopping.Tab.CreateOptionButton(button, - 2 * buttonHeight - 10, buttonHeight + 5, buttonHeight)
  end

  local function OnButtonAcquire(button, elementData)
    if not button.setup then
      SetupButton(button)
    end

    button:SetSize(self:GetWidth(), buttonHeight)
    button.options1:Hide()
    button.options2:Hide()
    button.options3:Hide()
    button:SetAlpha(1)

    local text = ""
    local xOffset
    button.elementData = elementData
    if elementData.type == RowType.List then
      xOffset = listHeaderInset
      local color = NORMAL_FONT_COLOR
      if elementData.list:IsTemporary() then
        color = ORANGE_FONT_COLOR
      end
      local icon = ""
      if not self:IsListExpanded(elementData.list) then
        icon = "|TInterface\\AddOns\\Auctionator\\Images\\Plus_Icon:8:8|t"
      else
        icon = "|TInterface\\AddOns\\Auctionator\\Images\\Minus_Icon:8:8|t"
      end
      button.Text:SetText(icon .. "  " .. color:WrapTextInColorCode(elementData.list:GetName()))
      button.options1.Icon:SetAtlas("common-search-magnifyingglass")
      button.options1:SetScript("OnClick", OnListSearchOptionClicked)
      button.options1.TooltipText = AUCTIONATOR_L_SEARCH_ALL
      button.options1:Show()
      button.options2.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Pen_Icon")
      button.options2:SetScript("OnClick", OnListEditOptionClicked)
      if elementData.list:IsTemporary() then
        button.options2.TooltipText = AUCTIONATOR_L_MAKE_PERMANENT
      else
        button.options2.TooltipText = AUCTIONATOR_L_RENAME
      end
      button.options2:Show()
      button.options3.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Trash_Icon")
      button.options3:SetScript("OnClick", OnListDeleteOptionClicked)
      button.options3.TooltipText = AUCTIONATOR_L_DELETE
      button.options3:Show()
    elseif elementData.type == RowType.SearchTerm then
      if elementData.index == self.draggingIndex then
        button:SetAlpha(draggingTermAlpha)
      end
      xOffset = listEntryInset
      button.Text:SetText(Auctionator.Search.PrettifySearchString(elementData.searchTerm))
      button.options1.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Trash_Icon")
      button.options1:SetScript("OnClick", OnSearchTermDeleteOptionClicked)
      button.options1.TooltipText = AUCTIONATOR_L_DELETE
      button.options1:Show()
      button.options2.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Pen_Icon")
      button.options2:SetScript("OnClick", OnSearchTermEditOptionClicked)
      button.options2.TooltipText = AUCTIONATOR_L_EDIT_ITEM
      button.options2:Show()
    else
      xOffset = listEntryInset
      button.Text:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(EMPTY))
    end

    button.Text:SetPoint("LEFT", button, "LEFT", xOffset, 0)
    button.Highlight:Hide()
    button.Selected:SetShown(elementData.type == RowType.List and self.expandedList and elementData.list:GetName() == self.expandedList:GetName())

    return button
  end

  self.Inset = CreateFrame("Frame", nil, self, "AuctionatorInsetTemplate")
  self.Inset:SetAllPoints()

  self.ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
  self.ScrollBox:SetPoint("TOPLEFT", 0, -2)
  self.ScrollBox:SetPoint("BOTTOMRIGHT", 0, 2)

  self.ScrollBar = CreateFrame("EventFrame", nil, self, "WowTrimScrollBar")
  self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT")
  self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")

  local view = CreateScrollBoxListLinearView(0, 0, 0, 0)
  view:SetElementExtent(buttonHeight)
  view:SetElementInitializer("Button", OnButtonAcquire)
  view:SetPanExtent(50)

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
end

function AuctionatorShoppingTabListsContainerMixin:Populate()
  local rows = {}

  for index = 1, Auctionator.Shopping.ListManager:GetCount() do
    local list = Auctionator.Shopping.ListManager:GetByIndex(index)
    table.insert(rows, {
      type = RowType.List,
      list = list,
    })
    if self:IsListExpanded(list) then
      for index, item in ipairs(list:GetAllItems()) do
        table.insert(rows, {
          type = RowType.SearchTerm,
          searchTerm = item,
          index = index,
          text = nil,
        })
      end
      if list:GetItemCount() == 0 then
        table.insert(rows, {
          type = RowType.Empty,
        })
      end
    end
  end
  self.ScrollBox:SetDataProvider(CreateDataProvider(rows), true)
end

