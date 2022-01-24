AuctionatorCraftSearchButtonMixin = {}

function AuctionatorCraftSearchButtonMixin:OnLoad()
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

function AuctionatorCraftSearchButtonMixin:ShowWhenEnchantAndAHOpen()
  self:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown() and GetCraftSelectionIndex() ~= 0)
end

function AuctionatorCraftSearchButtonMixin:UpdateTotal()
  self.Total:SetText(Auctionator.CraftSearch.GetInfoText())
end

function AuctionatorCraftSearchButtonMixin:OnClick()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.CraftSearch.DoCraftReagentsSearch()
  end
end

function AuctionatorCraftSearchButtonMixin:OnEvent(...)
  self:ShowWhenEnchantAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
