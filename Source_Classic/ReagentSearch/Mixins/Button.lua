AuctionatorReagentSearchButtonMixin = {}

function AuctionatorReagentSearchButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  hooksecurefunc(_G, "TradeSkillFrame_SetSelection", function(ecipeID)
    self:ShowWhenRecipeAndAHOpen()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    self:ShowWhenRecipeAndAHOpen()

    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
end

function AuctionatorReagentSearchButtonMixin:ShowWhenRecipeAndAHOpen()
  self:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown() and GetTradeSkillSelectionIndex() ~= 0)
end

function AuctionatorReagentSearchButtonMixin:UpdateTotal()
  self.Total:SetText(Auctionator.ReagentSearch.GetInfoText())
end

function AuctionatorReagentSearchButtonMixin:OnClick()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorReagentSearchButtonMixin:OnEvent(...)
  self:ShowWhenRecipeAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
