local function ValidateState(callerID, searchTerms)
  Auctionator.API.InternalVerifyID(callerID)

  --Validate arguments
  local cloned = Auctionator.Utilities.VerifyListTypes(searchTerms, "string")
  if not cloned then
    Auctionator.API.ComposeError(
      callerID, "Usage Auctionator.API.v1.MultiSearch(string, string[])"
    )
  end

  for _, term in ipairs(cloned) do
    if string.match(term, "\"") or string.match(term, ";") then
      Auctionator.API.ComposeError(
        callerID, "Search term contains \" or ;"
      )
    end
  end

  -- Validate state
  if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
    Auctionator.API.ComposeError(callerID, "Auction house is not open")
  end

  return cloned
end

local function StartSearch(callerID, cloned)
  -- Show the shopping list tab for results
  AuctionatorTabs_ShoppingLists:Click()

  local listName = callerID .. " (" .. AUCTIONATOR_L_TEMPORARY_LOWER_CASE .. ")"

  -- Remove any old searches
  if Auctionator.ShoppingLists.ListIndex(listName) ~= nil then
    Auctionator.ShoppingLists.Delete(listName)
  end

  Auctionator.ShoppingLists.CreateTemporary(listName)

  local list = Auctionator.ShoppingLists.GetListByName(listName)

  list.items = cloned

  Auctionator.EventBus:RegisterSource(StartSearch, "API v1 Multi search start")
    :Fire(StartSearch, Auctionator.ShoppingLists.Events.ListCreated, list)
    :Fire(StartSearch, Auctionator.ShoppingLists.Events.ListSearchRequested, list)
    :UnregisterSource(StartSearch)
end

function Auctionator.API.v1.MultiSearch(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)
  StartSearch(callerID, cloned)
end

function Auctionator.API.v1.MultiSearchExact(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)
  -- Make all the terms advanced search terms  which are exact
  for index, term in ipairs(cloned) do
    cloned[index] = '"' .. term .. '"'
  end

  StartSearch(callerID, cloned)
end
