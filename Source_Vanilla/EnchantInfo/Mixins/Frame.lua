AuctionatorEnchantInfoFrameMixin = {}

function AuctionatorEnchantInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  hooksecurefunc(_G, "CraftFrame_SetSelection", function(ecipeID)
    self:ShowWhenEnchantAndAHOpen()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    self:ShowWhenEnchantAndAHOpen()

    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
end

function AuctionatorEnchantInfoFrameMixin:ShowWhenEnchantAndAHOpen()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and GetCraftSelectionIndex() ~= 0)
  if self:IsShown() then
    self.SearchButton:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown())
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
  self:ShowWhenEnchantAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
