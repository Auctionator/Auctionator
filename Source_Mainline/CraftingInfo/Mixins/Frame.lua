AuctionatorCraftingInfoFrameMixin = {}

function AuctionatorCraftingInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })
  self:UpdateSearchButton()

  hooksecurefunc(ProfessionsFrame.CraftingPage.SchematicForm, "Init", function(...)
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
end

function AuctionatorCraftingInfoFrameMixin:ShowIfRelevant()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW))

  if self:IsShown() then
    self:ClearAllPoints()

    local reagents = ProfessionsFrame.CraftingPage.SchematicForm.Reagents
    local optionalReagents = ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents

    self:SetPoint("LEFT", reagents, "LEFT", 0, -10)

    if reagents:GetBottom() > optionalReagents:GetBottom() then
      self:SetPoint("TOP", optionalReagents, "BOTTOM")
    else
      self:SetPoint("TOP", reagents, "BOTTOM")
    end

    self:UpdateSearchButton()
  end
end

function AuctionatorCraftingInfoFrameMixin:UpdateSearchButton()
  self.SearchButton:SetShown(AuctionHouseFrame and AuctionHouseFrame:IsShown())
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
  else
    print("I would queue a search")
  end
end

function AuctionatorCraftingInfoFrameMixin:OnEvent(...)
  self:UpdateSearchButton()
end
