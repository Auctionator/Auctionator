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
    if button.elementData and button.elementData.type == RowType.SearchTerm then
      GameTooltip:SetOwner(button, "ANCHOR_NONE")
      Auctionator.Shopping.Tab.ComposeSearchTermTooltip(button.elementData.searchTerm)
      GameTooltip:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT")
      GameTooltip:Show()
    end
  end

  local function OnLeave(button)
    button.Highlight:Hide()
    if button.elementData and button.elementData.type == RowType.SearchTerm then
      GameTooltip:Hide()
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
    end)
    option:SetScript("OnLeave", function()
      option.Icon:SetAlpha(1)
    end)
    option:SetScript("OnHide", function()
      option.Icon:SetAlpha(1)
    end)
    return option
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
    local fontString = button:CreateFontString(nil, nil, "GameFontHighlightSmall")
    fontString:SetJustifyH("LEFT")
    fontString:SetPoint("LEFT", listHeaderInset, 0)
    fontString:SetPoint("RIGHT", button, "RIGHT", -buttonSpacing, 0)
    fontString:SetWordWrap(false)
    button.Text = fontString
    button.Bg = button:CreateTexture()
    button.Bg:SetAtlas("auctionhouse-rowstripe-1")
    button.Bg:SetBlendMode("ADD")
    button.Bg:SetAllPoints()
    button.Highlight = button:CreateTexture()
    button.Highlight:SetAtlas("auctionhouse-ui-row-highlight")
    button.Highlight:SetBlendMode("ADD")
    button.Highlight:SetAllPoints()
    button.Highlight:Hide()
    button.Selected = button:CreateTexture()
    button.Selected:SetAtlas("auctionhouse-ui-row-select")
    button.Selected:SetBlendMode("ADD")
    button.Selected:SetAllPoints()
    button.Selected:Hide()
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    button:SetScript("OnClick", OnClick)

    button.options1 = CreateOptionButton(button, 0, buttonHeight + 5)
    button.options2 = CreateOptionButton(button, -buttonHeight - 5, buttonHeight + 5)

    button.options1.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Trash_Icon")
    button.options1:SetScript("OnClick", OnRecentDeleteOptionClicked)

    button.options2.Icon:SetTexture("Interface\\AddOns\\Auctionator\\Images\\Copy_Icon")
    button.options2:SetScript("OnClick", OnRecentCopyOptionClicked)
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
  end

  local view = CreateScrollBoxListLinearView(0, 0, 0, 0)
  view:SetElementExtent(buttonHeight)
  if Auctionator.Constants.IsVanilla then
    view:SetElementInitializer("Button", nil, OnButtonAcquire)
  else
    view:SetElementInitializer("Button", OnButtonAcquire)
  end
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
