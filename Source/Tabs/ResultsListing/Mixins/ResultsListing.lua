AuctionatorResultsListingMixin = {}

function AuctionatorResultsListingMixin:Init(dataProvider)
  Auctionator.Debug.Message("AuctionatorResultsListingMixin:Init()")

  self.isInitialized = false
  self.dataProvider = dataProvider
  self.columnSpecification = self.dataProvider:GetTableLayout()

  Auctionator.EventBus:Register(self, { Auctionator.ShoppingLists.Events.ListDataProviderEmpty })

  -- Initialize ScrollFrame (HybridScrollFrame.lua#11)
  HybridScrollFrame_OnLoad(self.ScrollFrame)
  -- Add buttons to the scroll frame using our template (HybridScrollFrame.lua#201)
  HybridScrollFrame_CreateButtons(self.ScrollFrame, dataProvider:GetRowTemplate())
  -- Keey scroll bar visible (HybridScrollFrame.lua#255)
  HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true)

  -- Create an instance of table builder - note that the ScrollFrame we reference
  -- mixes a TableBuilder implementation in
  self.tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame))
  -- Set the frame that will be used for header columns for this tableBuilder
  self.tableBuilder:SetHeaderContainer(self.HeaderContainer)

  -- annoyingly, the table builder code loses the dataProvider's self reference
  -- when it assigns its GetEntryAt function internally, so overriding here so that we can
  -- use our DataProvider mixin
  self.tableBuilder.Populate = function(_, offset, count)
    self:PopulateOverride(offset, count)
  end

  self:InitializeTable()
  self:InitializeDataProvider()
end

function AuctionatorResultsListingMixin:ReceiveEvent(eventName, ...)
  if eventName == Auctionator.ShoppingLists.Events.ListDataProviderEmpty then
    self:DisableSpinner()
    self.ScrollFrame.NoResultsText:Show()
  end
end

function AuctionatorResultsListingMixin:InitializeDataProvider()
  self:DisableColumns()

  self.dataProvider:SetOnUpdateCallback(function()
    self:UpdateTable()
  end)

  self.dataProvider:SetOnSearchStartedCallback(function()
    self.ScrollFrame.NoResultsText:Hide()
    self:ClearColumnSorts()
    self:DisableColumns()
    self:EnableSpinner()
  end)

  self.dataProvider:SetOnSearchEndedCallback(function()
    self:RestoreScrollPosition()
    self:EnableColumns()
    self:DisableSpinner()
  end)

  self.dataProvider:SetOnPreserveScrollCallback(function()
    self.savedScrollPosition = self.ScrollFrame.scrollBar:GetValue()
  end)
end

function AuctionatorResultsListingMixin:RestoreScrollPosition()
  if self.savedScrollPosition == nil then
    return
  end

  local _, max = self.ScrollFrame.scrollBar:GetMinMaxValues()
  local val = math.min(self.savedScrollPosition or 0, max or 0)
  self.ScrollFrame.scrollBar:SetValue(val)
end

function AuctionatorResultsListingMixin:PopulateOverride(offset, count)
    local columns = self.tableBuilder:GetColumns();

    for rowIndex = 1, count do
      local dataIndex = rowIndex + offset;
      local rowData = self.dataProvider:GetEntryAt(dataIndex);
      if not rowData then
        break;
      end

      local row = self.tableBuilder:GetRowByIndex(rowIndex);

      if row then
        row.rowData = rowData;
        if row.Populate then
          row:Populate(rowData, dataIndex);
        end

        for columnIndex, _ in ipairs(columns) do
          local cell = self.tableBuilder:GetCellByIndex(rowIndex, columnIndex);
          if cell.Populate then
            cell.rowData = rowData;
            cell:Populate(rowData, dataIndex);
          end
        end
      end
    end
end

function AuctionatorResultsListingMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorResultsListingMixin:OnShow()", self.isInitialized)
  if not self.isInitialized then
    return
  end

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
  self.tableBuilder:SetDataProvider(self.dataProvider.GetEntryAt)
  self.tableBuilder:SetTableMargins(15)

  local column

  for _, columnEntry in ipairs(self.columnSpecification) do
    column = self.tableBuilder:AddColumn()
    column:ConstructHeader(
      "BUTTON",
      columnEntry.headerTemplate,
      columnEntry.headerText,
      function(sortKey, sortDirection)
        self:ClearColumnSorts()

        self.dataProvider:Sort(sortKey, sortDirection)
      end,
      unpack((columnEntry.headerParameters or {}))
    )
    column:SetCellPadding(5, 5)
    column:ConstructCells("FRAME", columnEntry.cellTemplate, unpack((columnEntry.cellParameters or {})))

    if columnEntry.width ~= nil then
      column:SetFixedConstraints(columnEntry.width, 0)
    else
      column:SetFillConstraints(1.0, 0)
    end
  end

  self.tableBuilder:Arrange()
  self.isInitialized = true
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

function AuctionatorResultsListingMixin:EnableColumns()
  for _, col in ipairs(self.tableBuilder:GetColumns()) do
    col.headerFrame:Enable()
  end
end

function AuctionatorResultsListingMixin:DisableColumns()
  for _, col in ipairs(self.tableBuilder:GetColumns()) do
    col.headerFrame:Disable()
  end
end
