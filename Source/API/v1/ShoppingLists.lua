---@param callerID string
---@param name string
---@return table | nil shoppingList
function Auctionator.API.v1.GetShoppingListByName(callerID, name)
  Auctionator.API.InternalVerifyID(callerID)

  if type(name) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetShoppingListByName(string, string)"
    )
  end

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(name)

  if not listIndex then
    Auctionator.API.ComposeError(
      callerID,
      "Auctionator.API.v1.GetShoppingListByName: List does not exist: " .. tostring(name)
    )
  end

  return Auctionator.Shopping.ListManager:GetByIndex(listIndex)
end

---@class Auctionator.API.v1.ShoppingLists.ShoppingListItem
---@field itemName string
---@field qualityID number? -- nil or between 1 and 5
---@field quantity number? -- nil or >= 1

--- Creates an Auctionator Shopping List and if at the AH, starts searching immediately. If a shopping list with the given name already exists it will be replaced
---@param callerID string
---@param name string
---@param items Auctionator.API.v1.ShoppingLists.ShoppingListItem[]
function Auctionator.API.v1.CreateShoppingList(callerID, name, items)
  Auctionator.API.InternalVerifyID(callerID)
  local function raiseError()
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.CreateShoppingList(string, string, ShoppingListItem[])"
    )
  end

  if type(name) ~= "string" or type(items) ~= "table" then
    raiseError()
  end

  local listExists = Auctionator.Shopping.ListManager:GetIndexForName(name)
  if listExists then
      Auctionator.Shopping.ListManager:Delete(name)
  end

  -- convert items to importstring
  ---@param shoppingListItem Auctionator.API.v1.ShoppingLists.ShoppingListItem
  ---@return string
  local function convertShoppingListItem(shoppingListItem)
    if type(shoppingListItem) ~= "table" then
      raiseError()
    end
    return Auctionator.API.v1.GetShoppingListItemString(callerID, shoppingListItem.itemName, shoppingListItem.qualityID, shoppingListItem.quantity)
  end

  local importString = name
  for _, shoppingListItem in pairs(items) do
    local itemAsString = convertShoppingListItem(shoppingListItem)
    if itemAsString ~= "" then
      importString = importString .. "^" .. convertShoppingListItem(shoppingListItem)
    end
  end

  Auctionator.Shopping.Lists.BatchImportFromString(importString)
end

---@param callerID string
---@param itemName string
---@param qualityID number?
---@param quantity number?
---@return string auctionatorShoppingListItemString
function Auctionator.API.v1.GetShoppingListItemString(callerID, itemName, qualityID, quantity)
  local function raiseError()
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetShoppingListItemString(string, string, 1 <= number? <= 5, 1 <= number?)"
    )
  end

  Auctionator.API.InternalVerifyID(callerID)
  if type(itemName) ~= "string" then
    raiseError()
  end
  if qualityID and (type(qualityID) ~= "number" or qualityID < 1 or qualityID > 5) then
    raiseError()
  end
  if quantity and (type(quantity) ~= "number") then
    raiseError()
  end
  if quantity and quantity <= 0 then
    return ""
  end
  return '"'..itemName..'"' .. ';;0;0;0;0;0;0;0;0;;'..(qualityID or '#')..';;' .. (quantity or '')
end