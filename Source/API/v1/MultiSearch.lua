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

function Auctionator.API.v1.MultiSearch(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)

  AuctionatorTabs_ShoppingLists:Click()

  Auctionator.EventBus:RegisterSource(Auctionator.API.v1.MultiSearch, "api v1 multisearch")
    :Fire(Auctionator.API.v1.MultiSearch, Auctionator.ShoppingLists.Events.FreeSearchRequested, cloned)
    :UnregisterSource(Auctionator.API.v1)
end

function Auctionator.API.v1.MultiSearchExact(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)

  AuctionatorTabs_ShoppingLists:Click()

  -- Make all the terms advanced search terms  which are exact
  for index, term in ipairs(cloned) do
    cloned[index] = '"' .. term .. '"'
  end

  Auctionator.EventBus:RegisterSource(Auctionator.API.v1.MultiSearchExact, "api v1 multisearch exact")
    :Fire(Auctionator.API.v1.MultiSearchExact, Auctionator.ShoppingLists.Events.FreeSearchRequested, cloned)
    :UnregisterSource(Auctionator.API.v1)
end
