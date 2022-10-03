AuctionatorAHFrameMixin = {}

local function InitializeAuctionHouseTabs()
  if Auctionator.State.TabFrameRef == nil then
    Auctionator.State.TabFrameRef = CreateFrame(
      "Frame",
      "AuctionatorAHTabsContainer",
      AuctionFrame,
      "AuctionatorAHTabsContainerTemplate"
    )
  end
end

local function InitializeBuyFrame()
  if Auctionator.State.BuyFrameRef == nil then
    Auctionator.State.BuyFrameRef = CreateFrame(
      "Frame",
      "AuctionatorBuyFrame",
      AuctionatorShoppingFrame,
      "AuctionatorBuyFrameTemplateForShopping"
    )
  end
end

local function InitializePageStatusDialog()
  if Auctionator.State.PageStatusFrameRef == nil then
    Auctionator.State.PageStatusFrameRef = CreateFrame(
      "Frame",
      "AuctionatorPageStatusDialogFrame",
      AuctionFrame,
      "AuctionatorPageStatusDialogTemplate"
    )
  end
end

local function InitializeThrottlingTimeoutDialog()
  if Auctionator.State.ThrottlingTimeoutFrameRef == nil then
    Auctionator.State.ThrottlingTimeoutFrameRef = CreateFrame(
      "Frame",
      "AuctionatorThrottlingTimeoutDialogFrame",
      AuctionFrame,
      "AuctionatorThrottlingTimeoutDialogTemplate"
    )
  end
end

local function ShowDefaultTab()
  local tabs = AuctionatorAHTabsContainer.Tabs

  local chosenTab = tabs[Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_TAB)]

  if chosenTab then
    chosenTab:Click()
  end
end

local function InitializeSplashScreen()
  if Auctionator.State.SplashScreenRef == nil then
    Auctionator.State.SplashScreenRef = CreateFrame(
      "Frame",
      "AuctionatorSplashScreen",
      UIParent,
      "AuctionatorSplashScreenTemplate"
    )
  end
end

local function InitializeFullScanFrame()
  if Auctionator.State.FullScanFrameRef == nil then
    Auctionator.State.FullScanFrameRef = CreateFrame(
      "FRAME",
      "AuctionatorFullScanFrame",
      AuctionHouseFrame,
      "AuctionatorFullScanFrameTemplate"
    )
  end
end

local setupSearchCategories = false
local function InitializeSearchCategories()
  if setupSearchCategories then
    return
  end

  Auctionator.Search.InitializeCategories()

  setTooltipHooks = true
end

function AuctionatorAHFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorAHFrameMixin:OnShow()")

  InitializeSearchCategories()
  InitializeAuctionHouseTabs()
  InitializeBuyFrame()
  InitializePageStatusDialog()
  InitializeThrottlingTimeoutDialog()
  InitializeFullScanFrame()
  InitializeSplashScreen()

  ShowDefaultTab()
end

function AuctionatorAHFrameMixin:OnEvent(eventName, ...)
  if eventName == "AUCTION_HOUSE_SHOW" then
    self:Show()
  elseif eventName == "AUCTION_HOUSE_CLOSED" then
    self:Hide()
  end
end
