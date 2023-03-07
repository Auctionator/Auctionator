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
    if string.match(term, "^%s*\".*\"%s*$") or string.match(term, ";") then
      Auctionator.API.ComposeError(
        callerID, "Search term contains ; or is wrapped in \""
      )
    end
  end

  -- Validate state
  if (not AuctionHouseFrame or not AuctionHouseFrame:IsShown()) and
     (not AuctionFrame      or not AuctionFrame:IsShown()) then
    Auctionator.API.ComposeError(callerID, "Auction house is not open")
  end

  return cloned
end

local function StartSearch(callerID, cloned)
  -- Show the shopping list tab for results
  AuctionatorTabs_Shopping:Click()

  local listName = callerID .. " (" .. AUCTIONATOR_L_TEMPORARY_LOWER_CASE .. ")"

  -- Remove any old searches
  if Auctionator.Shopping.ListManager:GetIndexForName(listName) ~= nil then
    Auctionator.Shopping.ListManager:Delete(listName)
  end

  Auctionator.Shopping.ListManager:Create(listName, true)

  local list = Auctionator.Shopping.ListManager:GetByName(listName)

  for _, item in ipairs(cloned) do
    list:InsertItem(item)
  end

  Auctionator.EventBus:RegisterSource(StartSearch, "API v1 Multi search start")
    :Fire(StartSearch, Auctionator.Shopping.Tab.Events.ListCreated, list)
    :Fire(StartSearch, Auctionator.Shopping.Tab.Events.ListSearchRequested, list)
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
