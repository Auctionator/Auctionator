AuctionatorCraftingInfoFrameMixin = {}

function AuctionatorCraftingInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  self.originalFirstLine = TradeSkillDescription or TradeSkillReagentLabel
  self.originalDescriptionPoint = {self.originalFirstLine:GetPoint(1)}

  hooksecurefunc(_G, "TradeSkillFrame_SetSelection", function(ecipeID)
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  self:ShowIfRelevant()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end

function AuctionatorCraftingInfoFrameMixin:ShowIfRelevant()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and GetTradeSkillSelectionIndex() ~= 0 and self:IsAnyReagents())
  if self:IsVisible() then
    self.SearchButton:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown())

    self.originalFirstLine:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
  else
    self.originalFirstLine:SetPoint(unpack(self.originalDescriptionPoint))
  end
end

-- Update the position of the search button and other anchors so that nothing
-- gets hidden if crafting costs are hidden but the search button for the AH is
-- left enabled.
function AuctionatorCraftingInfoFrameMixin:AdjustPosition()
  self:ClearAllPoints()
  self.SearchButton:ClearAllPoints()
  self:SetPoint(unpack(self.originalDescriptionPoint))
  if self:GetHeight() == 0 then
    self:SetPoint("LEFT")
    self:SetPoint("RIGHT")
    self.SearchButton:SetPoint("BOTTOMLEFT", 205, 6)
  else
    self.SearchButton:SetPoint("TOPLEFT", 205, 6)
  end
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoFrameMixin:IsAnyReagents()
  local recipeIndex = GetTradeSkillSelectionIndex()
  return GetTradeSkillNumReagents(recipeIndex) > 0
end

function AuctionatorCraftingInfoFrameMixin:UpdateTotal()
  local infoText, lines = Auctionator.CraftingInfo.GetInfoText()
  self.Total:SetText(infoText)
  self:SetHeight(16 * lines)

  self:AdjustPosition()
end

function AuctionatorCraftingInfoFrameMixin:SearchButtonClicked()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorCraftingInfoFrameMixin:OnEvent(...)
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
