AuctionatorCraftingInfoFrameMixin = {}

function AuctionatorCraftingInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  self.originalDescriptionPoint = {TradeSkillFrame.DetailsFrame.Contents.Description:GetPoint(1)}

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

function AuctionatorCraftingInfoFrameMixin:ShowWhenRecipeAndAHOpen()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and TradeSkillFrame.RecipeList:GetSelectedRecipeID() ~= nil and self:IsAnyReagents())

  if self:IsShown() then
    self.SearchButton:SetShown(AuctionHouseFrame ~= nil and AuctionHouseFrame:IsShown())

    self:SetPoint(unpack(self.originalDescriptionPoint))
    TradeSkillFrame.DetailsFrame.Contents.Description:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
  else
    TradeSkillFrame.DetailsFrame.Contents.Description:SetPoint(unpack(self.originalDescriptionPoint))
  end
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoFrameMixin:IsAnyReagents()
  local recipeIndex = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
  local recipeLevel = TradeSkillFrame.DetailsFrame:GetSelectedRecipeLevel()

  return C_TradeSkillUI.GetRecipeNumReagents(recipeIndex, recipeLevel) > 0
end

function AuctionatorCraftingInfoFrameMixin:UpdateTotal()
  self.Total:SetText(Auctionator.CraftingInfo.GetInfoText())
end

function AuctionatorCraftingInfoFrameMixin:SearchButtonClicked()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorCraftingInfoFrameMixin:OnEvent(...)
  self:ShowWhenRecipeAndAHOpen()
end
