AuctionatorTabMixin = {}

function AuctionatorTabMixin:Initialize(name, tabTemplate, tabHeader, displayMode)
  Auctionator.Debug.Message("AuctionatorTabMixin:Initialize()")

  self.ahTitle = tabHeader
  self.displayMode = displayMode

  self.wrapperFrame = CreateFrame("FRAME", nil, AuctionFrame, "AuctionatorTabWrapperTemplate")
  self.wrapperFrame.Title:SetText(self.ahTitle)
  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    displayMode[1],
    self.wrapperFrame,
    tabTemplate
  )
  self.frameRef:Hide()

  local index = AuctionFrame.numTabs + 1
  self:SetID(index)

  self:SetPoint("LEFT", _G["AuctionFrameTab" .. (index - 1)], "RIGHT", -15, 0)

  PanelTemplates_SetNumTabs(AuctionFrame, index)
  PanelTemplates_EnableTab(AuctionFrame, index)
  --PanelTemplates_DeselectTab(self)
end

function AuctionatorTabMixin:Selected()
  PanelTemplates_SetTab(AuctionFrame, self)
  PanelTemplates_SelectTab(self)
  self.wrapperFrame:Show()
  self.frameRef:Show()

  --AuctionHouseFrame:SetTitle(self.ahTitle)
  AuctionFrameTopLeft:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\topleft");
  AuctionFrameTop:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\top");
  AuctionFrameTopRight:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\topright");
  AuctionFrameBotLeft:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\botleft");
  AuctionFrameBot:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\bot");
  AuctionFrameBotRight:SetTexture("Interface\\AddOns\\Auctionator\\Images_Classic\\botright");
end

function AuctionatorTabMixin:DeselectTab()
  PanelTemplates_DeselectTab(self)
  self.wrapperFrame:Hide()
end
