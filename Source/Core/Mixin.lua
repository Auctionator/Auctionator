AuctionatorAHFrameMixin = {}

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

  if (
    Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN) and
    not Auctionator.Config.Get(Auctionator.Config.Options.ALTERNATE_SCAN_MODE)
  ) then
    frame:InitiateScan()
  end
end

local function InitializeIncrementalScanFrame()
  local frame
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

  if (
    Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN) and
    Auctionator.Config.Get(Auctionator.Config.Options.ALTERNATE_SCAN_MODE)
  ) then
    frame:InitiateScan()
  end
end

local function InitializeAuctionChatLogFrame()
  local frame
  if Auctionator.State.AuctionChatLogFrameRef == nil then
    frame = CreateFrame(
      "FRAME",
      "AuctionatorAuctionChatLogFrame",
      AuctionHouseFrame,
      "AuctionatorAuctionChatLogFrameTemplate"
    )

    Auctionator.State.AuctionChatLogFrameRef = frame
  else
    frame = Auctionator.State.AuctionChatLogFrameRef
  end
end

local function InitializeSellingFrame()
  if Auctionator.State.SellingFrameRef == nil then
    Auctionator.State.SellingFrameRef = CreateFrame(
      "FRAME",
      "AuctionatorSellingFrame",
      AuctionHouseFrame,
      "AuctionatorSellingFrameTemplate"
    )
  end
end

local function InitializeAuctionHouseTabs()
  if Auctionator.State.TabFrameRef == nil then
    Auctionator.State.TabFrameRef = CreateFrame(
      "Frame",
      "AuctionatorAHTabsContainer",
      AuctionHouseFrame,
      "AuctionatorAHTabsContainerTemplate"
    )
  end
end

local function InitializeSplashScreen()
  -- TODO Check for display setting before creating
  if Auctionator.State.SplashScreenRef == nil then
    Auctionator.State.SplashScreenRef = CreateFrame(
      "Frame",
      "AuctionatorSplashScreen",
      UIParent,
      "AuctionatorSplashScreenTemplate"
    )
  end

  local lastViewedSplashScreenVersion = Auctionator.Config.Get(Auctionator.Config.Options.SPLASH_SCREEN_VERSION)
  local mostRecentSplashScreenVersion = Auctionator.State.SplashScreenRef:GetMostRecentVersion()

  if lastViewedSplashScreenVersion ~= mostRecentSplashScreenVersion then
    Auctionator.Config.Set(
      Auctionator.Config.Options.HIDE_SPLASH_SCREEN,
      false
    )
  end

  if not Auctionator.Config.Get(Auctionator.Config.Options.HIDE_SPLASH_SCREEN) then
    Auctionator.State.SplashScreenRef:Show()
  end
end

local setTooltipHooks = false
local function InitializeLateTooltipHooks()
  if setTooltipHooks then
    return
  end

  Auctionator.Tooltip.LateHooks()

  setTooltipHooks = true
end

function AuctionatorAHFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorAHFrameMixin:OnShow()")

  InitializeFullScanFrame()
  InitializeIncrementalScanFrame()
  InitializeAuctionChatLogFrame()
  InitializeSellingFrame()
  InitializeLateTooltipHooks()

  InitializeAuctionHouseTabs()
  InitializeSplashScreen()
end

function AuctionatorAHFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:Show()
  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:Hide()
  end
end
