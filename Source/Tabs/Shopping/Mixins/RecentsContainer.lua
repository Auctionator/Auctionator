AuctionatorShoppingTabRecentsContainerMixin = {}

local listHeaderInset = 10
local buttonSpacing = 60
local buttonHeight = 20

function AuctionatorShoppingTabRecentsContainerMixin:SetOnSearchRecent(func)
  self.onSearchRecent = func
end

function AuctionatorShoppingTabRecentsContainerMixin:SetOnDeleteRecent(func)
  self.onDeleteRecent = func
end

function AuctionatorShoppingTabRecentsContainerMixin:SetOnCopyRecent(func)
  self.onCopyRecent = func
end

function AuctionatorShoppingTabRecentsContainerMixin:TemporarilySelectSearchTerm(searchTerm)
  self.ScrollBox:ForEachFrame(function(frame)
    frame.Selected:SetShown(frame.elementData == searchTerm)
  end)
end

function AuctionatorShoppingTabRecentsContainerMixin:OnLoad()
  self:SetupContent()

  if self:IsVisible() then
    self:Populate()
  end
end

function AuctionatorShoppingTabRecentsContainerMixin:OnShow()
  self:Populate()

  Auctionator.EventBus:Register(self, {
    Auctionator.Shopping.Events.RecentSearchesUpdate
  })
end

function AuctionatorShoppingTabRecentsContainerMixin:OnHide()
  Auctionator.EventBus:Unregister(self, {
    Auctionator.Shopping.Events.RecentSearchesUpdate
  })
end

function AuctionatorShoppingTabRecentsContainerMixin:ReceiveEvent(eventName, eventData)
  if eventName == Auctionator.Shopping.Events.RecentSearchesUpdate then
    self:Populate()
  end
end

function AuctionatorShoppingTabRecentsContainerMixin:SetupContent()
  local function OnClick(button)
    if self.onSearchRecent then
      self.onSearchRecent(button.elementData)
    end
  end

  local function OnEnter(button)
    button.Highlight:Show()
    GameTooltip:SetOwner(button, "ANCHOR_NONE")
    Auctionator.Shopping.Tab.ComposeSearchTermTooltip(button.elementData)
    GameTooltip:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT")
    GameTooltip:Show()
  end

  local function OnLeave(button)
    button.Highlight:Hide()
    GameTooltip:Hide()
  end

  local function OnRecentDeleteOptionClicked(button)
    button = button:GetParent()
    if self.onDeleteRecent then
      self.onDeleteRecent(button.elementData)
    end
  end

  local function OnRecentCopyOptionClicked(button)
    button = button:GetParent()
    if self.onCopyRecent then
      self.onCopyRecent(button.elementData)
    end
  end

  local function SetupButton(button)
    button.setup = true
    Auctionator.Shopping.Tab.SetupContainerRow(button, buttonHeight, buttonSpacing)
    button.Text:SetPoint("LEFT", listHeaderInset, 0)

    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:SetScript("OnClick", OnClick)

    button.options1 = Auctionator.Shopping.Tab.CreateOptionButton(button, 0, buttonHeight + 5, buttonHeight)
    button.options2 = Auctionator.Shopping.Tab.CreateOptionButton(button, -buttonHeight - 5, buttonHeight + 5, buttonHeight)

    button.options1.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Trash_Icon")
    button.options1:SetScript("OnClick", OnRecentDeleteOptionClicked)
    button.options1.TooltipText = AUCTIONATOR_L_DELETE

    button.options2.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Copy_Icon")
    button.options2:SetScript("OnClick", OnRecentCopyOptionClicked)
    button.options2.TooltipText = AUCTIONATOR_L_COPY_TO_LIST
  end

  self.Inset = CreateFrame("Frame", nil, self, "AuctionatorInsetTemplate")
  self.Inset:SetAllPoints()

  self.ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
  self.ScrollBox:SetPoint("TOPLEFT", 0, -2)
  self.ScrollBox:SetPoint("BOTTOMRIGHT", 0, 2)

  self.ScrollBar = CreateFrame("EventFrame", nil, self, "WowTrimScrollBar")
  self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT")
  self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")

  local function OnButtonAcquire(button, elementData)
    if not button.setup then
      SetupButton(button)
    end
    button.elementData = elementData
    button.Text:SetText(Auctionator.Search.PrettifySearchString(elementData))
    button.Selected:Hide()
  end

  local view = CreateScrollBoxListLinearView(0, 0, 0, 0)
  view:SetElementExtent(buttonHeight)
  view:SetElementInitializer("Button", OnButtonAcquire)
  view:SetPanExtent(50)

  ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)
end

function AuctionatorShoppingTabRecentsContainerMixin:Populate()
  local rows = {}

  for _, recent in ipairs(Auctionator.Shopping.Recents.GetAll()) do
    table.insert(rows, recent)
  end
  self.ScrollBox:SetDataProvider(CreateDataProvider(rows), true)
end
