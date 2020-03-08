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

  InitializeAPIv1MultiSearchFrame()
  Auctionator.State.AuctionAPIv1MultiSearchFrameRef:StartSearch(cloned)
end
