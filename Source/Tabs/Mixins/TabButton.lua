AuctionatorTabMixin = {}

function AuctionatorTabMixin:Initialize(name, tabTemplate, tabHeader, displayMode)
  Auctionator.Debug.Message("AuctionatorTabMixin:Initialize()")

  self.ahTitle = tabHeader
  self.displayMode = displayMode

  PanelTemplates_DeselectTab(self)

  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    displayMode[1],
    AuctionHouseFrame,
    tabTemplate
  )
  self.frameRef:Hide()
  AuctionHouseFrame.tabsForDisplayMode[name] = #AuctionHouseFrame.Tabs

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
