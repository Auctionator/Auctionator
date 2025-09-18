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
    if string.match(term, "^%s*\".*\"%s*$") or string.match(term, ";^") then
      Auctionator.API.ComposeError(
        callerID, "Search term contains ; or ^ or is wrapped in \""
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

  list:AppendItems(cloned)

  Auctionator.EventBus:RegisterSource(StartSearch, "API v1 Multi search start")
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

local function ValidateExtendedSearchTerms(callerID, searchTerms)
  for index, term in ipairs(searchTerms) do
    if term.searchString == nil or type(term.searchString) ~= "string" then
      Auctionator.API.ComposeError(
        callerID, "Auctionator.API.v1.MultiSearchAdvanced search term " .. index .. " must have searchString key"
      )
    end
  end
  local cleaned = {}
  for index, term in ipairs(searchTerms) do
    local newTerm = {}
    for key, value in pairs(term) do
      if type(key) == "string" and (type(value) == "number" or type(value) == "string" or type(value) == "boolean") then
        if type(value) == "string" and (string.match(value, "^\".*\"$") or string.match(value, "[;^]")) then
          Auctionator.API.ComposeError(
            callerID, "Search term " .. index .. " key " .. key .. " contains ; or ^ or is wrapped in \""
          )
        end
        newTerm[key] = value
      else
        Auctionator.API.ComposeError(
          callerID, "Bad search term " .. index .. ", contains something invalid at '" ..tostring(key) .. "'"
        )
      end
    end
    if term.categoryKey == nil then
      newTerm.categoryKey = ""
    end
    table.insert(cleaned, newTerm)
  end
  return cleaned
end

function Auctionator.API.v1.MultiSearchAdvanced(callerID, searchTerms)
  local cleanedTerms = ValidateExtendedSearchTerms(callerID, searchTerms)

  local internalSearchTerms = {}
  for _, term in ipairs(cleanedTerms) do
    table.insert(internalSearchTerms, Auctionator.Search.ReconstituteAdvancedSearch(term))
  end

  StartSearch(callerID, internalSearchTerms)
end
