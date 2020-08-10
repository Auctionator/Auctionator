AuctionatorTabMixin = {}

function AuctionatorTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorTabMixin:OnLoad()")

  if self.frameTemplate == nil then
    error("A frameTemplate is required for Auctionator to initialize this tab")
  end
  if self.displayModeKey == nil then
    error("A displayModeKey is required for Auctionator to initialize this tab")
  end
  if self.ahTabIndex == nil or type(self.ahTabIndex) ~= "number" then
    error("A numerical ahTabIndex is required for Auctionator to initialize this tab")
  end
  if self.ahTitle == nil then
    self.ahTitle = "Auctionator"
  end

  PanelTemplates_DeselectTab(self)

  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    self.displayMode[1],
    AuctionHouseFrame,
    self.frameTemplate
  )
  self.frameRef:Hide()

  AuctionHouseFrame.tabsForDisplayMode[self.displayModeKey] = self.ahTabIndex

  self:SetPoint("LEFT", AuctionHouseFrame.Tabs[#AuctionHouseFrame.Tabs - 1], "RIGHT", -15, 0)
end

function AuctionatorTabMixin:Selected()
  PanelTemplates_SetTab(AuctionHouseFrame, self)
  PanelTemplates_SelectTab(self)

  AuctionHouseFrame:SetTitle(self.ahTitle)
end

function AuctionatorTabMixin:DeselectTab()
  PanelTemplates_DeselectTab(self)
  self.frameRef:Hide()
end
