AuctionatorTabMixin = {}

function AuctionatorTabMixin:Initialize(name, tabTemplate, tabHeader, displayMode)
  Auctionator.Debug.Message("AuctionatorTabMixin:Initialize()")

  self.ahTitle = tabHeader
  self.displayMode = displayMode

  local wrapperFrame = CreateFrame("FRAME", nil, AuctionFrame, "AuctionatorTabWrapperTemplate")
  -- Create this tab's frame
  self.frameRef = CreateFrame(
    "FRAME",
    displayMode[1],
    wrapperFrame,
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
  self.frameRef:Show()

  --AuctionHouseFrame:SetTitle(self.ahTitle)
  AuctionFrameTopLeft:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\topleft");
  AuctionFrameTop:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\top");
  AuctionFrameTopRight:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\topright");
  AuctionFrameBotLeft:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\botleft");
  AuctionFrameBot:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\bot");
  AuctionFrameBotRight:SetTexture("Interface\\AddOns\\Auctionator\\Images_TBC\\botright");
end

function AuctionatorTabMixin:DeselectTab()
  PanelTemplates_DeselectTab(self)
  self.frameRef:Hide()
end
