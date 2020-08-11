AuctionatorDataProviderMixin = {}

-- AuctionatorDataProviderMixin registers for the following events for derived mixins:
--   1. Auctionator.ShoppingLists.Events.ListResultItemProcessed
function AuctionatorDataProviderMixin:OnLoad()
  self.results = {}
  self.insertedKeys = {}
  self.entriesToProcess = {}
  self.processCountPerUpdate = 10

  self.searchCompleted = false

  -- Just so I don't have to test for update functions later
  self.onEntryProcessed = function(_) end
  self.onUpdate = function() end
  self.onSearchStarted = function() end
  self.onSearchEnded = function() end
  self.onPreserveScroll = function() end
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

  self.searchCompleted = false
end

-- Derive: This will be used to help with sorting and filtering unique entries
function AuctionatorDataProviderMixin:UniqueKey(entry)
end

-- Derive: This is the template for sorting the dataset contained by this provider
function AuctionatorDataProviderMixin:Sort(fieldName, sortDirection)
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

function AuctionatorDataProviderMixin:SetOnPreserveScrollCallback(onPreserveScrollCallback)
  self.onPreserveScroll = onPreserveScrollCallback
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
    return
  end

  Auctionator.Debug.Message("AuctionatorDataProviderMixin:CheckForEntriesToProcess()")

  local processCount = 0
  local entry
  local key

  while processCount < self.processCountPerUpdate and #self.entriesToProcess > 0 do
    processCount = processCount + 1
    entry = table.remove(self.entriesToProcess)

    key = self:UniqueKey(entry)
    if self.insertedKeys[key] == nil then
      self.insertedKeys[key] = entry
      table.insert(self.results, entry)

      self.onEntryProcessed(entry)
    end
  end

  if #self.entriesToProcess == 0 and self.searchCompleted then
    self.onSearchEnded()
    self.announcedCompletion = true
  end

  self.onUpdate(self.results)
end
