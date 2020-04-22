local function InitializeAPIv1MultiSearchFrame()
  if Auctionator.State.APIv1MultiSearchFrameRef == nil then
    local frame = CreateFrame(
      "FRAME",
      "AuctionatorAPIv1MultiSearchFrame",
      AuctionHouseFrame,
      "AuctionatorAPIv1MultiSearchFrameTemplate"
    )

    Auctionator.State.AuctionAPIv1MultiSearchFrameRef = frame
  end
end

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

  InitializeAPIv1MultiSearchFrame()
  Auctionator.State.AuctionAPIv1MultiSearchFrameRef:StartSearch(cloned)
end

function Auctionator.API.v1.MultiSearchExact(callerID, searchTerms)
  local cloned = ValidateState(callerID, searchTerms)

  -- Make all the terms advanced search terms  which are exact
  for index, term in ipairs(cloned) do
    cloned[index] = '"' .. term .. '"'
  end

  InitializeAPIv1MultiSearchFrame()
  Auctionator.State.AuctionAPIv1MultiSearchFrameRef:StartSearch(cloned)
end
