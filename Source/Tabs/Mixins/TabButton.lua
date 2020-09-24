AuctionatorTabMixin = {}

function AuctionatorTabMixin:OnLoad()
  self:RegisterEvent("DISPLAY_SIZE_CHANGED")

  Auctionator.Debug.Message("AuctionatorTabMixin:OnLoad()")

  if self.frameTemplate == nil then
    error("A frameTemplate is required for Auctionator to initialize this tab")
  end
  if self.displayModeKey == nil then
    error("A displayModeKey is required for Auctionator to initialize this tab")
  end
  if self.ahTitle == nil then
    self.ahTitle = "Auctionator"
  end

  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    self.displayMode[1],
    AuctionHouseFrame,
    self.frameTemplate
  )

  AuctionHouseFrameDisplayMode[self.displayModeKey] = self.displayMode
  AuctionHouseFrame.tabsForDisplayMode[self.displayMode] = #AuctionHouseFrame.Tabs
  PanelTemplates_SetNumTabs(AuctionHouseFrame, #AuctionHouseFrame.Tabs)
end
