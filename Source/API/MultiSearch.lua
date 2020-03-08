local function InitializeAPIMultiSearchFrame()
  if Auctionator.State.APIMultiSearchFrameRef == nil then
    local frame = CreateFrame(
      "FRAME",
      "AuctionatorAPIMultiSearchFrame",
      AuctionHouseFrame,
      "AuctionatorAPIMultiSearchFrameTemplate"
    )

    Auctionator.State.AuctionAPIMultiSearchFrameRef = frame
  end
end

function Auctionator.API.v1.MultiSearch(callerID, searchTerms)
  Auctionator.API.InternalVerifyID(callerID)

  --Validate arguments
  local cloned = Auctionator.Utilities.VerifyListTypes(searchTerms, "string")
  if not cloned then
    Auctionator.API.ComposeError(
      callerID, "Usage Auctionator.API.v1.MultiSearch(string[])"
    )
  end
  -- Validate state
  if not AuctionHouseFrame or not AuctionHouseFrame:IsShown() then
    Auctionator.API.ComposeError(callerID, "Auction house is not open")
  end

  InitializeAPIMultiSearchFrame()
  Auctionator.State.AuctionAPIMultiSearchFrameRef:StartSearch(cloned)
end
