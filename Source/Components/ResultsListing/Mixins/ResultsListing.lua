AuctionatorResultsListingMixin = {}

function AuctionatorResultsListingMixin:Init(dataProvider)
  Auctionator.Debug.Message("AuctionatorResultsListingMixin:Init()")

  self.isInitialized = false
  self.dataProvider = dataProvider
  self.columnSpecification = self.dataProvider:GetTableLayout()

  -- Initialize ScrollFrame (HybridScrollFrame.lua#11)
  HybridScrollFrame_OnLoad(self.ScrollFrame)
  -- Add buttons to the scroll frame using our template (HybridScrollFrame.lua#201)
  HybridScrollFrame_CreateButtons(self.ScrollFrame, dataProvider:GetRowTemplate())
  -- Keey scroll bar visible (HybridScrollFrame.lua#255)
  HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true)

  -- Create an instance of table builder - note that the ScrollFrame we reference
  -- mixes a TableBuilder implementation in
  self.tableBuilder = AuctionatorRetailImportCreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame))
  -- Set the frame that will be used for header columns for this tableBuilder
  self.tableBuilder:SetHeaderContainer(self.HeaderContainer)

  self:InitializeTable()
  self:InitializeDataProvider()
end

function AuctionatorResultsListingMixin:InitializeDataProvider()
  self.dataProvider:SetOnUpdateCallback(function()
    self:UpdateTable()
  end)

  self.dataProvider:SetOnSearchStartedCallback(function()
    self.ScrollFrame.NoResultsText:Hide()
    self:EnableSpinner()
  end)

  self.dataProvider:SetOnSearchEndedCallback(function()
    self:RestoreScrollPosition()
    self:DisableSpinner()

    self.ScrollFrame.NoResultsText:SetShown(self.dataProvider:GetCount() == 0)
  end)

  self.dataProvider:SetOnPreserveScrollCallback(function()
    self.savedScrollPosition = self.ScrollFrame.scrollBar:GetValue()
  end)

  self.dataProvider:SetOnResetScrollCallback(function()
    self.savedScrollPosition = nil
  end)
end

function AuctionatorResultsListingMixin:RestoreScrollPosition()
  if self.savedScrollPosition == nil then
    return
  end

  -- Ensure all the visuals are positioned (so the scroll restores correctly)
  self:UpdateTable()

  local _, max = self.ScrollFrame.scrollBar:GetMinMaxValues()
  local val = math.min(self.savedScrollPosition or 0, max or 0)
  self.ScrollFrame.scrollBar:SetValue(val)
end

function AuctionatorResultsListingMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorResultsListingMixin:OnShow()", self.isInitialized)
  if not self.isInitialized then
    return
  end

  self:UpdateForHiding()
  self:UpdateTable()
end

-- TODO I can't figure out where the magic is that causes this to be invoked...
-- I think its in one of the HybridScrollFrame_ methods that SetScript(OnUpdate...)?
function AuctionatorResultsListingMixin:OnUpdate()
  if not self.isInitialized then
    return
  end

  self:UpdateTable()
end

function AuctionatorResultsListingMixin:InitializeTable()
  self.tableBuilder:Reset()
  self.tableBuilder:SetDataProvider(function(index)
    return self.dataProvider:GetEntryAt(index)
  end)
  self.tableBuilder:SetTableMargins(15)

  local column

  for _, columnEntry in ipairs(self.columnSpecification) do
    column = self.tableBuilder:AddColumn()
    column:ConstructHeader(
      "BUTTON",
      columnEntry.headerTemplate,
      columnEntry.headerText,
      function()
        self:CustomiseColumns()
      end,
      function(sortKey, sortDirection)
        self:ClearColumnSorts()

        self.dataProvider:SetPresetSort(sortKey, sortDirection)
        self.dataProvider:Sort(sortKey, sortDirection)
      end,
      function()
        self:ClearColumnSorts()

        self.dataProvider:ClearSort()
      end,
      unpack((columnEntry.headerParameters or {}))
    )
    column:SetCellPadding(-5, 5)
    column:ConstructCells("FRAME", columnEntry.cellTemplate, unpack((columnEntry.cellParameters or {})))

    if columnEntry.width ~= nil then
      column:SetFixedConstraints(columnEntry.width, 0)
    else
      column:SetFillConstraints(1.0, 0)
    end
  end
  self.isInitialized = true
  self:UpdateForHiding()
end

function AuctionatorResultsListingMixin:UpdateTable()
  if not self.isInitialized then
    return
  end

  local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
  local buttonCount = #buttons
  local displayCount = self.dataProvider:GetCount()
  local buttonHeight = buttons[1]:GetHeight()
  local visibleElementHeight = displayCount * buttonHeight

  local offset = HybridScrollFrame_GetOffset(self.ScrollFrame)
  local populateCount = math.min(buttonCount, displayCount)

  self.tableBuilder:Populate(offset, populateCount)

  for i = 1, buttonCount do
    local visible = i <= displayCount
    buttons[i]:SetShown(visible)
  end

  local regionHeight = self.ScrollFrame:GetHeight()
  HybridScrollFrame_Update(self.ScrollFrame, visibleElementHeight, regionHeight)
end

function AuctionatorResultsListingMixin:ClearColumnSorts()
  for _, col in ipairs(self.tableBuilder:GetColumns()) do
    col.headerFrame.Arrow:Hide()
  end
end

function AuctionatorResultsListingMixin:CustomiseColumns()
  if self.dataProvider:GetColumnHideStates() ~= nil then
    self.CustomiseDropDown:Callback(
      self.columnSpecification,
      self.dataProvider:GetColumnHideStates(),
      function()
        self:UpdateForHiding()
    end)
  end
end

local function SetColumnShown(column, isShown)
  column:GetHeaderFrame():SetShown(isShown)
  for _, cell in ipairs(column.cells) do
    cell:SetShown(isShown)
  end
end

function AuctionatorResultsListingMixin:UpdateForHiding()
  if not self.dataProvider:GetColumnHideStates() then
    self.tableBuilder:Arrange()
    return
  end

  local hidingDetails = self.dataProvider:GetColumnHideStates()

  local anyFlexibleWidths = false
  local visibleColumn

  for index, column in ipairs(self.tableBuilder:GetColumns()) do
    local columnEntry = self.columnSpecification[index]

    -- Import default value if hidden state not already set.
    if hidingDetails[columnEntry.headerText] == nil then
      hidingDetails[columnEntry.headerText] = columnEntry.defaultHide or false
    end

    if hidingDetails[columnEntry.headerText] then
      SetColumnShown(column, false)
      column:SetFixedConstraints(0.001, 0)
    else
      SetColumnShown(column, true)

      if columnEntry.width ~= nil then
        column:SetFixedConstraints(columnEntry.width, 0)
      else
        anyFlexibleWidths = true
        column:SetFillConstraints(1.0, 0)
      end

      if visibleColumn == nil then
        visibleColumn = column
      end
    end
  end

  -- Checking that at least one column will fill up empty space, if there isn't
  -- one, the first visible column is modified to do so.
  if not anyFlexibleWidths then
    visibleColumn:SetFillConstraints(1.0, 0)
  end

  self.tableBuilder:Arrange()
end

function AuctionatorResultsListingMixin:EnableSpinner()
  self.ScrollFrame.ResultsText:Show()
  self.ScrollFrame.LoadingSpinner:Show()
  self.ScrollFrame.SpinnerAnim:Play()
end

function AuctionatorResultsListingMixin:DisableSpinner()
  self.ScrollFrame.ResultsText:Hide()
  self.ScrollFrame.LoadingSpinner:Hide()
  self.ScrollFrame.SpinnerAnim:Stop()
end
