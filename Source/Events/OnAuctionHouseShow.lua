local function InitializeShoppingListFrame()
  local frame
  if Auctionator.State.ShoppingListFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorShoppingLists",
      AuctionHouseFrame,
      "AuctionatorShoppingListFrameTemplate"
    )

    Auctionator.State.ShoppingListFrameRef = frame
  else
    frame = Auctionator.State.ShoppingListFrameRef
  end

  frame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", -2, 0)
  frame:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMRIGHT", -2, 0)
  frame:Show()
end

local function InitializeScanFrame()
  local frame
  if Auctionator.State.ScanFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorFullScanFrame",
      AuctionHouseFrame,
      "AuctionatorFullScanFrameTemplate"
    )

    Auctionator.State.ScanFrameRef = frame
  else
    frame = Auctionator.State.ScanFrameRef
    frame:InitiateScan()
  end

  frame:RegisterForEvents()
end

local function InitializeMultiSearchFrame()
  local frame
  if Auctionator.State.MultiSearchFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorMultiSearchFrame",
      AuctionHouseFrame,
      "AuctionatorMultiSearchFrameTemplate"
    )

    Auctionator.State.MultiSearchFrameRef = frame
  else
    frame = Auctionator.State.MultiSearchFrameRef
  end

  frame:RegisterForEvents()
end

function Auctionator.Events.OnAuctionHouseShow()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow()")

  InitializeShoppingListFrame()
  InitializeScanFrame()
  InitializeMultiSearchFrame()
end
