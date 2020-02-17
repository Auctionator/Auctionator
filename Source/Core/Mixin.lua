AuctionatorAHFrameMixin = {}

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

function AuctionatorAHFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorAHFrameMixin:OnLoad()")

  InitializeShoppingListFrame()
  InitializeScanFrame()

  AuctionatorToggle:SetPoint("BOTTOMRIGHT", AuctionHouseFrame, "TOPRIGHT")
  AuctionatorToggle:Show()
end

function AuctionatorAHFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:Show()
  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:Hide()
    Auctionator.State.ShoppingListFrameRef:Hide()
  end
end

function AuctionatorAHFrameMixin:ToggleShoppingLists()
  if AuctionatorShoppingLists:IsVisible() then
    AuctionatorShoppingLists:Hide()
  else
    AuctionatorShoppingLists:Show()
  end
end