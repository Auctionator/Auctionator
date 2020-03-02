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

local function InitializeFullScanFrame()
  local frame
  if Auctionator.State.FullScanFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorFullScanFrame",
      AuctionHouseFrame,
      "AuctionatorFullScanFrameTemplate"
    )

    Auctionator.State.FullScanFrameRef = frame
  else
    frame = Auctionator.State.FullScanFrameRef
  end
  if Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN) then
    frame:InitiateScan()
  end
end

local function InitializeIncrementalScanFrame()
  if Auctionator.State.IncrementalScanFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorIncrementalScanFrame",
      AuctionHouseFrame,
      "AuctionatorIncrementalScanFrameTemplate"
    )

    Auctionator.State.IncrementalScanFrameRef = frame
  else
    frame = Auctionator.State.IncrementalScanFrameRef
  end
end

local function InitializeAuctionatorButtonFrame()
  AuctionatorButtonFrame:SetPoint("BOTTOMRIGHT", AuctionHouseFrame, "TOPRIGHT")
  AuctionatorButtonFrame:Show()
end

function AuctionatorAHFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorAHFrameMixin:OnShow()")

  InitializeFullScanFrame()
  InitializeIncrementalScanFrame()
  InitializeShoppingListFrame()
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
  Auctionator.State.FullScanFrameRef:InitiateScan()
end
