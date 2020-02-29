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
  if Auctionator.Config.Get(Auctionator.Config.Options.SHOW_LISTS) then
    frame:Show()
  end
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
  end
  if Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN) then
    frame:InitiateScan()
  end
end

local function InitializeAuctionatorButtonFrame()
  AuctionatorButtonFrame:SetPoint("BOTTOMRIGHT", AuctionHouseFrame, "TOPRIGHT")
  AuctionatorButtonFrame:Show()
end

function AuctionatorAHFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorAHFrameMixin:OnShow()")

  InitializeShoppingListFrame()
  InitializeScanFrame()
  InitializeAuctionatorButtonFrame()
end

function AuctionatorAHFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:Show()
  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:Hide()
    Auctionator.State.ShoppingListFrameRef:Hide()
  end
end

AuctionatorButtonFrameMixin = {}

function AuctionatorButtonFrameMixin:ToggleShoppingLists()
  if AuctionatorShoppingLists:IsVisible() then
    AuctionatorShoppingLists:Hide()
  else
    AuctionatorShoppingLists:Show()
  end
end

function AuctionatorButtonFrameMixin:AutoScan()
  Auctionator.State.ScanFrameRef:InitiateScan()
end
