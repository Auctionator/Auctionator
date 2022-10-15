AuctionatorEnchantInfoSearchButtonMixin = {}

function AuctionatorEnchantInfoSearchButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

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

function AuctionatorEnchantInfoSearchButtonMixin:ShowWhenEnchantAndAHOpen()
  self:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown() and GetCraftSelectionIndex() ~= 0)
end

function AuctionatorEnchantInfoSearchButtonMixin:UpdateTotal()
  self.Total:SetText(Auctionator.EnchantInfo.GetInfoText())
end

function AuctionatorEnchantInfoSearchButtonMixin:OnClick()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.EnchantInfo.DoCraftReagentsSearch()
  end
end

function AuctionatorEnchantInfoSearchButtonMixin:OnEvent(...)
  self:ShowWhenEnchantAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
