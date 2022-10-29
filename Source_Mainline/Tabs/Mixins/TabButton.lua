AuctionatorTabMixin = {}

function AuctionatorTabMixin:Initialize(name, tabTemplate, tabHeader, displayMode)
  Auctionator.Debug.Message("AuctionatorTabMixin:Initialize()")

  self.ahTitle = tabHeader
  self.displayMode = displayMode


  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    displayMode[1],
    AuctionHouseFrame,
    tabTemplate
  )
  self.frameRef:Hide()
  AuctionHouseFrame.tabsForDisplayMode[name] = #AuctionHouseFrame.Tabs

  PanelTemplates_SetNumTabs(AuctionHouseFrame, #AuctionHouseFrame.Tabs)
  PanelTemplates_DeselectTab(self)
  self:OnShow()
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

function AuctionatorTabMixin:OnShow()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SMALL_TABS) then
    AuctionHouseFrameTabMixin.OnShow(self)
  end
end
