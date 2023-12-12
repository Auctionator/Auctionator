---@param callerID string
---@param shoppingListName string
---@return table<number, string> shoppingListItems
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

  local shoppingList =  Auctionator.Shopping.ListManager:GetByIndex(listIndex)
  return shoppingList:GetAllItems()
end

---@class Auctionator.Search.SearchTerm
---@field searchString string
---@field categoryKey string
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

--- Creates an Auctionator Shopping List and if at the AH, starts searching immediately. If a shopping list with the given name already exists it will be replaced
---@param callerID string
---@param name string
---@param terms Auctionator.Search.SearchTerm[]
function Auctionator.API.v1.CreateShoppingList(callerID, name, terms)
  Auctionator.API.InternalVerifyID(callerID)

  if type(name) ~= "string" or type(terms) ~= "table" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.CreateShoppingList(string, string, Auctionator.Search.SearchTerm[])"
    )
  end

  local listExists = Auctionator.Shopping.ListManager:GetIndexForName(name)
  if listExists then
      Auctionator.Shopping.ListManager:Delete(name)
  end

  local importString = name
  for _, searchTerm in pairs(terms) do
    if (searchTerm.quantity and searchTerm.quantity > 0) or not searchTerm.quantity then
      local success, itemString = pcall(Auctionator.Search.ReconstituteAdvancedSearch, searchTerm)
      if success then
        importString = importString .. "^" .. tostring(itemString)
      else
        Auctionator.API.ComposeError(
        callerID,
        "Error in Auctionator.Search.ReconstituteAdvancedSearch(Auctionator.Search.SearchTerm):\n" .. tostring(itemString)
        )
      end
    end
  end

  local success, error = pcall(Auctionator.Shopping.Lists.BatchImportFromString, importString)
  if not success then
    Auctionator.API.ComposeError(
      callerID,
      "Error in Auctionator.API.v1.CreateShoppingList/Auctionator.Shopping.Lists.BatchImportFromString(shoppingListString):\n" .. tostring(error)
    )
  end
end

---@param callerID string
---@param shoppingListName string
---@param itemTerm Auctionator.Search.SearchTerm
function Auctionator.API.v1.DeleteShoppingListItem(callerID, shoppingListName, itemTerm)
  Auctionator.API.InternalVerifyID(callerID)

  if type(shoppingListName) ~= "string" or type(itemTerm) ~= "table" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.RemoveItemFromShoppingList(string, string, Auctionator.Search.SearchTerm)"
    )
  end

  local listIndex = Auctionator.Shopping.ListManager:GetIndexForName(shoppingListName)
  if not listIndex then
    Auctionator.API.ComposeError(
      callerID,
      "Auctionator.API.v1.RemoveItemFromShoppingList ShoppingList does not exist: " .. tostring(shoppingListName)
    )
  end

  local shoppingList = Auctionator.Shopping.ListManager:GetByIndex(listIndex)

  local success, itemSearchString = pcall(Auctionator.Search.ReconstituteAdvancedSearch, itemTerm)
  if not success then
    Auctionator.API.ComposeError(
        callerID,
        "Error in Auctionator.API.v1.DeleteShoppingListItem/Auctionator.Search.ReconstituteAdvancedSearch(Auctionator.Search.SearchTerm):\n" .. tostring(itemSearchString)
        )
  end

  local itemIndex = shoppingList:GetIndexForItem(itemSearchString)
  if itemIndex then
    shoppingList:DeleteItem(itemIndex)
  end
end

---@param callerID string
---@param shoppingListName string
---@param oldItemTerm Auctionator.Search.SearchTerm
---@param newItemTerm Auctionator.Search.SearchTerm
function Auctionator.API.v1.AlterShoppingListItem(callerID, shoppingListName, oldItemTerm, newItemTerm)
  Auctionator.API.InternalVerifyID(callerID)

  if type(shoppingListName) ~= "string" or type(oldItemTerm) ~= "table" or type(newItemTerm) ~= "table" then
    Auctionator.API.ComposeError(
      callerID,
      "Usage Auctionator.API.v1.AlterShoppingListItem(string, string, Auctionator.Search.SearchTerm, Auctionator.Search.SearchTerm)"
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

  local s1, oldItemSearchString = pcall(Auctionator.Search.ReconstituteAdvancedSearch, oldItemTerm)
  if not s1 then
    Auctionator.API.ComposeError(
        callerID,
        "Error in Auctionator.API.v1.AlterShoppingListItem/Auctionator.Search.ReconstituteAdvancedSearch(Auctionator.Search.SearchTerm):\n" .. tostring(oldItemSearchString)
        )
  end

  local s2, newItemSearchString = pcall(Auctionator.Search.ReconstituteAdvancedSearch, newItemTerm)
  if not s2 then
    Auctionator.API.ComposeError(
        callerID,
        "Error in Auctionator.API.v1.AlterShoppingListItem/Auctionator.Search.ReconstituteAdvancedSearch(Auctionator.Search.SearchTerm):\n" .. tostring(newItemSearchString)
        )
  end

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

  local s1, e1 = pcall(Auctionator.API.v1.CreateShoppingList, callerID, shoppingListName, creationTerms)
  assert(s1, "CreateShoppingList failed: " .. tostring(e1))

  local s2, items = pcall(Auctionator.API.v1.GetShoppingListItems, callerID, shoppingListName)
  assert(s2, "GetShoppingListItems failed: " .. tostring(items))

  assert(items[1] ~= '"Draconium Ore";;;;;;;;;;;2;;15 ', "Shopping List Creation failed")
  assert(items[2] ~= '"Serevite Ore";;;;;;;;;;;3;;10 ', "Shopping List Creation failed")

  local s3, e3 = pcall(Auctionator.API.v1.DeleteShoppingListItem, callerID, shoppingListName, {
        searchString="Draconium Ore",
        isExact=true,
        categoryKey="",
        tier=2,
        quantity=15,
  })

  assert(s3, "DeleteShoppingListItem failed: " .. tostring(e3))

  items = Auctionator.API.v1.GetShoppingListItems(callerID, shoppingListName)

  assert(items[1] ~= '"Serevite Ore";;;;;;;;;;;3;;10 ', "DeleteShoppingListItem failed")
  assert(items[2] ~= "nil", "DeleteShoppingListItem failed")

  local s4, e4 = pcall(Auctionator.API.v1.AlterShoppingListItem, callerID, shoppingListName, 
    {
        searchString="Serevite Ore",
        isExact=true,
        categoryKey="",
        tier=3,
        quantity=10,
    }, {
        searchString="Draconium Ore",
        isExact=true,
        categoryKey="",
        tier=2,
        quantity=5,      
  })
  assert(s4, "AlterShoppingListItem failed: " .. tostring(e4))

  items = Auctionator.API.v1.GetShoppingListItems(callerID, shoppingListName)

  assert(items[1] ~= '"Draconium Ore";;;;;;;;;;;2;;5 ', "AlterShoppingListItem failed")
  assert(items[2] ~= "nil", "AlterShoppingListItem failed")

  print("ShoppingListAPITests Successful")
end