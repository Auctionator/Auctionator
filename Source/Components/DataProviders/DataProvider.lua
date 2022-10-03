AuctionatorDataProviderMixin = {}

function AuctionatorDataProviderMixin:OnLoad()
  self.results = {}
  self.insertedKeys = {}
  self.entriesToProcess = {}
  self.processCountPerUpdate = 200
  self.presetSort = {key = nil, direction = nil}

  self.searchCompleted = false

  -- Just so I don't have to test for update functions later
  self.onEntryProcessed = function(_)
    self:NotifyCacheUsed()
  end
  self.onUpdate = function() end
  self.onSearchStarted = function() end
  self.onSearchEnded = function() end
  self.onPreserveScroll = function() end
  self.onResetScroll = function() end
end

function AuctionatorDataProviderMixin:OnUpdate(elapsed)
  if elapsed >= 0 then
    self:CheckForEntriesToProcess()
  end
end

function AuctionatorDataProviderMixin:Reset()
  self.results = {}
  self.insertedKeys = {}
  self.entriesToProcess = {}
  self.processingIndex = 0

  self.searchCompleted = false
end

-- Derive: This will be used to help with sorting and filtering unique entries
function AuctionatorDataProviderMixin:UniqueKey(entry)
end

-- Derive: This is the template for sorting the dataset contained by this provider
function AuctionatorDataProviderMixin:Sort(fieldName, sortDirection)
end

-- Sets sorting fieldName/sortDirection to use as data is being processed. Set
-- either to nil to disable any sorting.
function AuctionatorDataProviderMixin:SetPresetSort(fieldName, sortDirection)
  self.presetSort.key = fieldName
  self.presetSort.direction = sortDirection
end

-- Uses sortingIndex to restore original order before sorting
function AuctionatorDataProviderMixin:ClearSort()
  self:SetPresetSort(nil, nil)
  table.sort(self.results, function(left, right)
    return left.sortingIndex < right.sortingIndex
  end)
end


-- Derive: This defines the Results Listing table layout
-- The table layout should be an array of table layout column entries consisting of:
--   1. REQUIRED headerTemplate - String
--      The name of the frame template that should be used for the column header
--   2. OPTIONAL headerParameters - Array<Any>
--      An array of any elements that we want to pass to the column header; these will
--      be supplied to the column header's Init method
--   3. REQUIRED headerText - String
--      The text that should be displayed in the column header
--   4. REQUIRED cellTemplate - String
--      The name of the frame template that should be used for cells in this column
--   5. OPTIONAL cellParameters - Array<Any>
--      An array of any elements that we want to pass to the cell; these will be
--      supplied to the cell's Init method
--   6. OPTIONAL width - Integer
--      If supplied, this will be used to define the column's fixed width.
--      If omitted, the column will use ColumnWidthConstraints.Fill from TableBuilder
function AuctionatorDataProviderMixin:GetTableLayout()
  return {}
end

-- Derive: This sets table which stores the options for saving the customised
-- column view.  If this is nil, it won't be possible to customise the columns.
function AuctionatorDataProviderMixin:GetColumnHideStates()
  return nil
end

function AuctionatorDataProviderMixin:GetRowTemplate()
  return "AuctionatorResultsRowTemplate"
end

function AuctionatorDataProviderMixin:GetEntryAt(index)
  -- Auctionator.Debug.Message("INDEX", index)

  return self.results[index]
end

function AuctionatorDataProviderMixin:GetCount()
  return #self.results
end

function AuctionatorDataProviderMixin:SetOnEntryProcessedCallback(onEntryProcessedCallback)
  self.onEntryProcessed = onEntryProcessedCallback
end

function AuctionatorDataProviderMixin:SetOnUpdateCallback(onUpdateCallback)
  self.onUpdate = onUpdateCallback
end

function AuctionatorDataProviderMixin:SetOnSearchStartedCallback(onSearchStartedCallback)
  self.onSearchStarted = onSearchStartedCallback
end

function AuctionatorDataProviderMixin:SetOnSearchEndedCallback(onSearchEndedCallback)
  self.onSearchEnded = onSearchEndedCallback
end

function AuctionatorDataProviderMixin:NotifyCacheUsed()
  self.cacheUsedCount = self.cacheUsedCount + 1
end

function AuctionatorDataProviderMixin:SetDirty()
  self.isDirty = true
end

function AuctionatorDataProviderMixin:SetOnPreserveScrollCallback(onPreserveScrollCallback)
  self.onPreserveScroll = onPreserveScrollCallback
end

function AuctionatorDataProviderMixin:SetOnResetScrollCallback(onResetScrollCallback)
  self.onResetScroll = onResetScrollCallback
end

function AuctionatorDataProviderMixin:AppendEntries(entries, isLastSetOfResults)
  Auctionator.Debug.Message("AuctionatorDataProviderMixin:AppendEntries()", #entries)

  self.searchCompleted = isLastSetOfResults
  self.announcedCompletion = false

  for _, entry in ipairs(entries) do
    table.insert(self.entriesToProcess, entry)
  end
end

-- We process a limited number of entries every frame to avoid freezing the
-- client.
function AuctionatorDataProviderMixin:CheckForEntriesToProcess()
  if #self.entriesToProcess == 0 then
    if not self.announcedCompletion and self.searchCompleted then
      self.announcedCompletion = true
      self.onSearchEnded()
    end

    if self.isDirty then
      self.onUpdate(self.results)
      self.isDirty = false
    end

    return
  end

  Auctionator.Debug.Message("AuctionatorDataProviderMixin:CheckForEntriesToProcess()")

  local processCount = 0
  local entry
  local key

  self.cacheUsedCount = 0

  while processCount < self.processCountPerUpdate + self.cacheUsedCount and self.processingIndex < #self.entriesToProcess do
    self.processingIndex = self.processingIndex + 1
    entry = self.entriesToProcess[self.processingIndex]

    key = self:UniqueKey(entry)
    if self.insertedKeys[key] == nil then
      processCount = processCount + 1
      self.insertedKeys[key] = entry
      table.insert(self.results, entry)

      --Used to keep items in a consistent order when fields are identical and sorting
      entry.sortingIndex = #self.results

      self.onEntryProcessed(entry)
    end
  end

  if self.presetSort.key ~= nil and self.presetSort.direction ~= nil then
    self:Sort(self.presetSort.key, self.presetSort.direction)
  end

  local resetQueue = false
  if self.processingIndex == #self.entriesToProcess then
    self.entriesToProcess = {}
    self.processingIndex = 0
    resetQueue = true
  end

  if resetQueue and self.searchCompleted then
    self.onSearchEnded()
    self.announcedCompletion = true
  end

  self.onUpdate(self.results)
  self.isDirty = false
end

local function WrapCSVParameter(parameter)
  if type(parameter) == "string" then
    return "\"" .. string.gsub(parameter, "\"", "") .. "\""
  else
    return tostring(parameter)
  end
end

function AuctionatorDataProviderMixin:GetCSV(callback)
  if self:GetCount() == 0 then
    callback("")
  end

  local csvResult = ""

  local layout = self:GetTableLayout()

  for index, column in ipairs(layout) do
    csvResult = csvResult .. WrapCSVParameter(column.headerText)

    if index ~= #layout then
      csvResult = csvResult ..  ","
    end
  end
  csvResult = csvResult .. "\n"

  local function DoRows(start, finish)
    finish = math.min(finish, self:GetCount())

    local index = start
    while index <= finish do
      local row = self.results[index]
      for column, cell in ipairs(layout) do
        csvResult = csvResult .. WrapCSVParameter(row[cell.headerParameters[1]])

        if column ~= #layout then
          csvResult = csvResult .. ","
        end
      end

      if index ~= self:GetCount() then
        csvResult = csvResult .. "\n"
      end

      index = index + 1
    end

    if finish < self:GetCount() then
      C_Timer.After(0, function()
        DoRows(finish + 1, (finish - start) + finish + 1)
      end)
    else
      callback(csvResult)
    end
  end

  DoRows(1, 50)
end
