AuctionatorCraftingInfoSearchButtonMixin = {}

function AuctionatorCraftingInfoSearchButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  hooksecurefunc(TradeSkillFrame, "OnRecipeChanged", function(_, recipeID)
    self:ShowWhenRecipeAndAHOpen()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
  hooksecurefunc(TradeSkillFrame.DetailsFrame, "SetSelectedRecipeLevel", function(_, newLevel)
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

function AuctionatorCraftingInfoSearchButtonMixin:ShowWhenRecipeAndAHOpen()
  self:SetShown(AuctionHouseFrame ~= nil and AuctionHouseFrame:IsShown() and TradeSkillFrame.RecipeList:GetSelectedRecipeID() ~= nil and self:IsAnyReagents())
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoSearchButtonMixin:IsAnyReagents()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  return C_TradeSkillUI.GetRecipeNumReagents(recipeIndex, recipeLevel) > 0
end

function AuctionatorCraftingInfoSearchButtonMixin:UpdateTotal()
  self.Total:SetText(Auctionator.CraftingInfo.GetInfoText())
end

function AuctionatorCraftingInfoSearchButtonMixin:OnClick()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorCraftingInfoSearchButtonMixin:OnEvent(...)
  self:ShowWhenRecipeAndAHOpen()
end
