DataProviderMixin = {}

function DataProviderMixin:OnLoad()
  self.results = {}
  self.insertedKeys = {}

  -- Just so I don't have to test for update functions later
  self.onUpdate = function() end
end

function DataProviderMixin:Reset()
  self.results = {}
  self.insertedKeys = {}
end

-- Derive: This will be used to help with sorting and filtering unique entries
function DataProviderMixin:UniqueKey(entry)
end

-- Derive: This is the template for sorting the dataset contained by this provider
function DataProviderMixin:Sort(fieldName, sortDirection)
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
function DataProviderMixin:GetTableLayout()
  return {}
end

function DataProviderMixin:GetRowTemplate()
  return "AuctionatorResultsRowTemplate"
end

function DataProviderMixin:GetEntryAt(index)
  -- Auctionator.Debug.Message("INDEX", index)

  return self.results[index]
end

function DataProviderMixin:GetCount()
  return #self.results
end

function DataProviderMixin:SetOnUpdateCallback(onUpdateCallback)
  self.onUpdate = onUpdateCallback
end

function DataProviderMixin:AppendEntries(entries, processEntryCallback)
  if processEntryCallback == nil then
    processEntryCallback = function(_) end
  end

  local key

  for _, entry in ipairs(entries) do
    key = self:UniqueKey(entry)

    if self.insertedKeys[key] == nil then
      self.insertedKeys[key] = entry

      processEntryCallback(entry)
      table.insert(self.results, entry)
    end
  end

  self.onUpdate(self.results)
end