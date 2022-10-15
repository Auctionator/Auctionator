AuctionatorCraftingInfoSearchButtonMixin = {}

function AuctionatorCraftingInfoSearchButtonMixin:OnLoad()
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
  self:ShowWhenRecipeAndAHOpen()
end

function AuctionatorCraftingInfoSearchButtonMixin:ShowWhenRecipeAndAHOpen()
  self:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown() and GetTradeSkillSelectionIndex() ~= 0 and self:IsAnyReagents())
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoSearchButtonMixin:IsAnyReagents()
  local recipeIndex = GetTradeSkillSelectionIndex()
  return GetTradeSkillNumReagents(recipeIndex) > 0
end

function AuctionatorCraftingInfoSearchButtonMixin:UpdateTotal()
  self.Total:SetText(Auctionator.CraftingInfo.GetInfoText())
end

function AuctionatorCraftingInfoSearchButtonMixin:OnClick()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorCraftingInfoSearchButtonMixin:OnEvent(...)
  self:ShowWhenRecipeAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
