AuctionatorCraftingInfoFrameMixin = {}

function AuctionatorCraftingInfoFrameMixin:OnLoad()
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

function AuctionatorCraftingInfoFrameMixin:ShowWhenRecipeAndAHOpen()
  self:SetShown(GetTradeSkillSelectionIndex() ~= 0 and self:IsAnyReagents())
  self.SearchButton:SetShown(AuctionFrame ~= nil and AuctionFrame:IsShown())
  if self:IsShown() then
    self:UpdateTotal()
  end
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoFrameMixin:IsAnyReagents()
  local recipeIndex = GetTradeSkillSelectionIndex()
  return GetTradeSkillNumReagents(recipeIndex) > 0
end

function AuctionatorCraftingInfoFrameMixin:UpdateTotal()
  self.Total:SetText(Auctionator.CraftingInfo.GetInfoText())
end

function AuctionatorCraftingInfoFrameMixin:SearchButtonClicked()
  if AuctionFrame and AuctionFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorCraftingInfoFrameMixin:OnEvent(...)
  self:ShowWhenRecipeAndAHOpen()
  if self:IsVisible() then
    self:UpdateTotal()
  end
end
