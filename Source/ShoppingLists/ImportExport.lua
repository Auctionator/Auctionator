function Auctionator.ShoppingLists.GetBatchExportString(listName)
  local list = Auctionator.ShoppingLists.GetListByName(listName)

  local result = listName
  for _, item in ipairs(list.items) do
    result = result .. "^" .. item
  end

  return result
end

--Import multiple instance of lists in the format
--  list name^item 1^item 2\n
function Auctionator.ShoppingLists.BatchImportFromString(importString)
  -- Remove blank lines
  importString = gsub(importString, "%s+\n", "\n")
  importString = gsub(importString, "\n+", "\n")

  local lists = {strsplit("\n", importString)}

  for index, list in ipairs(lists) do
    local name, items = strsplit("^", list, 2)

    if Auctionator.ShoppingLists.ListIndex(name) == nil and name ~= nil and name:len() > 0 then
      Auctionator.ShoppingLists.Create(name)
    end

    Auctionator.ShoppingLists.OneImportFromString(name, items)
  end
end

function Auctionator.ShoppingLists.OneImportFromString(listName, importString)
  Auctionator.Debug.Message("Auctionator.ShoppingLists.OneImportFromString()", listName, importString)

  if importString == nil then
    -- Otherwise import throws when there are not items in a list
    return
  end

  local list = Auctionator.ShoppingLists.GetListByName(listName)

  list.items = {strsplit("^", importString)}
end

--Import multiple instances of lists in the format
-- **List Name\n
-- Item 1\n
-- Item 2\n
function Auctionator.ShoppingLists.OldBatchImportFromString(importString)
  -- Remove blank lines
  importString = gsub(importString, "%s+\n", "")
  -- Simplify *** to *
  importString = gsub(importString, "*+%s*", "*")
  -- Remove first *
  importString = gsub(importString, "^*", "")

  local lists = {strsplit("*", importString)}

  for index, list in ipairs(lists) do
    local name, items = strsplit("\n", list, 2)

    if Auctionator.ShoppingLists.ListIndex(name) == nil then
      Auctionator.ShoppingLists.Create(name)
    end

    Auctionator.ShoppingLists.OldOneImportFromString(name, items)
  end
end

function Auctionator.ShoppingLists.OldOneImportFromString(listName, importString)
  local list = Auctionator.ShoppingLists.GetListByName(listName)

  importString = gsub(importString, "\n$", "")

  list.items = {strsplit("\n", importString)}
end

local TSMImportName = "TSM (" .. AUCTIONATOR_L_TEMPORARY_LOWER_CASE .. ")"

--Import a TSM group in the format
--  i:itemID 1,i:itemID 2 OR
--  itemID 1,itemID 2
--
--Saves the result in a temporary list and fires a list creation event.
function Auctionator.ShoppingLists.TSMImportFromString(importString)
  -- Remove line breaks
  importString = gsub(importString, "\n", "")

  local itemStrings = {strsplit(",", importString)}
  local left = #itemStrings
  local items = {}

  for index, itemString in ipairs(itemStrings) do
    --TSM uses the same format for normal items and pets, so we try to load an
    --item with the ID first, if that doesn't work, then we try loading a pet.
    local match = string.match(itemString, "^i:(%d+)$")

    local id = tonumber(match) or tonumber(itemString)

    local item = Item:CreateFromItemID(id)
    if item:IsItemEmpty() then
      item = Item:CreateFromItemID(Auctionator.Constants.PET_CAGE_ID)
    end

    item:ContinueOnItemLoad(function()
      items[index] = GetItemInfo(id)
      if items[index] == nil then
        items[index] = C_PetJournal.GetPetInfoBySpeciesID(id)
      end

      if items[index] == nil then
        items[index] = "IMPORT ERROR"
      end

      left = left - 1
      if left == 0 then
        if Auctionator.ShoppingLists.ListIndex(TSMImportName) ~= nil then
          Auctionator.ShoppingLists.Delete(TSMImportName)
        end

        Auctionator.ShoppingLists.CreateTemporary(TSMImportName)

        local list = Auctionator.ShoppingLists.GetListByName(TSMImportName)
        list.items = items

        Auctionator.EventBus
          :RegisterSource(Auctionator.ShoppingLists.TSMImportFromString, "TSMImportFromString")
          :Fire(Auctionator.ShoppingLists.TSMImportFromString, Auctionator.ShoppingLists.Events.ListCreated, list)
          :UnregisterSource(Auctionator.ShoppingLists.TSMImportFromString)
        end
    end)
  end
end
