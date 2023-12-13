---@class Auctionator.Search.SearchTerm
---@field searchString string
---@field categoryKey string?
---@field isExact boolean?
---@field minLevel number?
---@field maxLevel number?
---@field minPrice number?
---@field maxPrice number?
---@field minItemLevel number?
---@field maxItemLevel number?
---@field minCraftedLevel number?
---@field maxCraftedLevel number?
---@field quality number?
---@field tier number? -- dragonflight crafted reagent quality ([1,5])
---@field expansion string?
---@field quantity number?


---@param callerID string
---@param term Auctionator.Search.SearchTerm
---@return string searchString
function Auctionator.API.v1.ConvertToSearchString(callerID, term)
  if not term or not term.searchString or type(term.searchString) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.ConvertToSearchString(table)"
    )
  end
  return Auctionator.Search.ReconstituteAdvancedSearch(term)
end

---@param callerID string
---@param searchString string
---@return Auctionator.Search.SearchTerm searchTerm
function Auctionator.API.v1.ConvertFromSearchString(callerID, searchString)
  if not searchString or type(searchString) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.ConvertFromSearchString(string)"
    )
  end
  return Auctionator.Search.SplitAdvancedSearch(searchString)
end

---@param callerID string
---@param shoppingListName string
---@return string[]
function Auctionator.API.v1.GetShoppingListItems(callerID, shoppingListName)
  Auctionator.API.InternalVerifyID(callerID)

  if type(shoppingListName) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.GetShoppingListItems(string, string)"
    )
  end

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(shoppingListName)

  if not listIndex then
    Auctionator.API.ComposeError(
      callerID,
      "Auctionator.API.v1.GetShoppingListItems: List does not exist: " .. tostring(shoppingListName)
    )
  end

  local shoppingList = Auctionator.Shopping.ListManager:GetByIndex(listIndex)

  return shoppingList:GetAllItems()
end

--- Creates an Auctionator Shopping List and if at the AH, starts searching immediately. If a shopping list with the given name already exists it will be replaced
---@param callerID string
---@param name string
---@param searchStrings string[]
function Auctionator.API.v1.CreateShoppingList(callerID, name, searchStrings)
  Auctionator.API.InternalVerifyID(callerID)

  if type(name) ~= "string" or type(searchStrings) ~= "table" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.CreateShoppingList(string, string, string[])"
    )
  end

  local listExists = Auctionator.Shopping.ListManager:GetIndexForName(name)
  if listExists then
      Auctionator.Shopping.ListManager:Delete(name)
  end

  Auctionator.Shopping.ListManager:Create(name)
  local list = Auctionator.Shopping.ListManager:GetByName(name)
  list:AppendItems(searchStrings)

  Auctionator.EventBus
    :RegisterSource(Auctionator.API.v1.CreateShoppingList, "Auctionator.API.v1.CreateShoppingList")
    :Fire(Auctionator.API.v1.CreateShoppingList, Auctionator.Shopping.Events.ListImportFinished, name)
end

---@param callerID string
---@param shoppingListName string
---@param itemSearchString string
function Auctionator.API.v1.DeleteShoppingListItem(callerID, shoppingListName, itemSearchString)
  Auctionator.API.InternalVerifyID(callerID)

  if type(shoppingListName) ~= "string" or type(itemSearchString) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.DeleteShoppingListItem(string, string, string)"
    )
  end

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(shoppingListName)
  if not listIndex then
    Auctionator.API.ComposeError(
      callerID,
      "Auctionator.API.v1.DeleteShoppingListItem ShoppingList does not exist: " .. tostring(shoppingListName)
    )
  end

  local shoppingList = Auctionator.Shopping.ListManager:GetByIndex(listIndex)

  local itemIndex = shoppingList:GetIndexForItem(itemSearchString)
  if itemIndex then
    shoppingList:DeleteItem(itemIndex)
  end
end

---@param callerID string
---@param shoppingListName string
---@param oldItemSearchString string
---@param newItemSearchString string
function Auctionator.API.v1.AlterShoppingListItem(callerID, shoppingListName, oldItemSearchString, newItemSearchString)
  Auctionator.API.InternalVerifyID(callerID)

  if type(shoppingListName) ~= "string" or type(oldItemSearchString) ~= "string" or type(newItemSearchString) ~= "string" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.AlterShoppingListItem(string, string, string, string)"
    )
  end

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(shoppingListName)
  if not listIndex then
    Auctionator.API.ComposeError(
      callerID,
      "Auctionator.API.v1.AlterShoppingListItem ShoppingList does not exist: " .. tostring(shoppingListName)
    )
  end

  local shoppingList = Auctionator.Shopping.ListManager:GetByIndex(listIndex)

  local oldItemIndex = shoppingList:GetIndexForItem(oldItemSearchString)
  if oldItemIndex then
    shoppingList:AlterItem(oldItemIndex, newItemSearchString)
  else
    Auctionator.API.ComposeError(
        callerID,
        "Error in Auctionator.API.v1.AlterShoppingListItem: Could not find item in shopping list:\n" .. tostring(oldItemSearchString)
        )
  end
end

--- Very Simple Testing of API
function Auctionator.API.v1.ShoppingListAPITests()
  local callerID = "APITest"
  local shoppingListName = "APITestShoppingList"
  local creationTerms = {
    {
        searchString="Draconium Ore",
        isExact=true,
        categoryKey="",
        tier=2,
        quantity=15,
    },
    {
        searchString="Serevite Ore",
        isExact=true,
        categoryKey="",
        tier=3,
        quantity=10,   
    }
  }
  local searchStrings = {}
  for _, term in ipairs(creationTerms) do
    table.insert(searchStrings, Auctionator.API.v1.ConvertToSearchString(callerID, term))
  end

  local s1, e1 = pcall(Auctionator.API.v1.CreateShoppingList, callerID, shoppingListName, searchStrings)
  assert(s1, "CreateShoppingList failed: " .. tostring(e1))

  local s2, items = pcall(Auctionator.API.v1.GetShoppingListItems, callerID, shoppingListName)
  assert(s2, "GetShoppingListItems failed: " .. tostring(items))

  assert(items[1] == '"Draconium Ore";;;;;;;;;;;2;;15', "Shopping List Creation failed")
  assert(items[2] == '"Serevite Ore";;;;;;;;;;;3;;10', "Shopping List Creation failed")

  local s3, e3 = pcall(Auctionator.API.v1.DeleteShoppingListItem, callerID, shoppingListName, searchStrings[1])

  assert(s3, "DeleteShoppingListItem failed: " .. tostring(e3))

  items = Auctionator.API.v1.GetShoppingListItems(callerID, shoppingListName)

  assert(items[1] == '"Serevite Ore";;;;;;;;;;;3;;10', "DeleteShoppingListItem failed")
  assert(#items < 2, "DeleteShoppingListItem failed")

  local s4, e4 = pcall(Auctionator.API.v1.AlterShoppingListItem, callerID, shoppingListName, 
  Auctionator.API.v1.ConvertToSearchString(callerID, {
        searchString="Serevite Ore",
        isExact=true,
        tier=3,
        quantity=10,
  }), Auctionator.API.v1.ConvertToSearchString(callerID, {
        searchString="Draconium Ore",
        isExact=true,
        tier=2,
        quantity=5,      
  }))
  assert(s4, "AlterShoppingListItem failed: " .. tostring(e4))

  items = Auctionator.API.v1.GetShoppingListItems(callerID, shoppingListName)

  assert(items[1] == '"Draconium Ore";;;;;;;;;;;2;;5', "AlterShoppingListItem failed")
  assert(#items <  2, "AlterShoppingListItem failed")

  print("ShoppingListAPITests Successful")
end
