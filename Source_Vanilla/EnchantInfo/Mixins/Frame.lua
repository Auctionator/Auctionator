AuctionatorEnchantInfoFrameMixin = {}

function AuctionatorEnchantInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  self.originalFirstLine = CraftDescription or CraftReagentLabel
  self.originalDescriptionPoint = {self.originalFirstLine:GetPoint(1)}

  hooksecurefunc(_G, "CraftFrame_SetSelection", function(ecipeID)
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

function AuctionatorEnchantInfoFrameMixin:ShowIfRelevant()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and GetCraftSelectionIndex() ~= 0)
  if self:IsVisible() then
    self.SearchButton:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown())

    self:SetPoint(unpack(self.originalDescriptionPoint))
    self.originalFirstLine:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
  else
    self.originalFirstLine:SetPoint(unpack(self.originalDescriptionPoint))
  end
end

function AuctionatorEnchantInfoFrameMixin:UpdateTotal()
  self.Total:SetText(Auctionator.EnchantInfo.GetInfoText())
end

function AuctionatorEnchantInfoFrameMixin:SearchButtonClicked()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.EnchantInfo.DoCraftReagentsSearch()
  end
end

function AuctionatorEnchantInfoFrameMixin:OnEvent(...)
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
