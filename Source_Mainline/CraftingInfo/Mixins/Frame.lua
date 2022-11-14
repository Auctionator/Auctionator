AuctionatorCraftingInfoFrameMixin = {}

function AuctionatorCraftingInfoFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
  })
  self:UpdateSearchButton()

  -- Uses Init rather than an event as the event handler can fire before the
  -- ProfessionsPane pane has finished initialising a recipe
  hooksecurefunc(ProfessionsFrame.CraftingPage.SchematicForm, "Init", function(...)
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)

  ProfessionsFrame.CraftingPage.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, function()
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end, self)

  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
end

function AuctionatorCraftingInfoFrameMixin:ShowIfRelevant()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo() ~= nil)

  if self:IsVisible() then
    self:ClearAllPoints()

    local reagents = ProfessionsFrame.CraftingPage.SchematicForm.Reagents
    local framesToBeBelow = {
      ProfessionsFrame.CraftingPage.SchematicForm.OptionalReagents,
    }
    for _, f in ipairs(ProfessionsFrame.CraftingPage.SchematicForm.extraSlotFrames) do
      table.insert(framesToBeBelow, f)
    end
    local min = reagents
    for _, f in ipairs(framesToBeBelow) do
      if f:GetBottom() < min:GetBottom() then
        min = f
      end
    end

    self:SetPoint("LEFT", reagents, "LEFT", 0, -10)

    self:SetPoint("TOP", min, "BOTTOM")

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
  local text, lines = Auctionator.CraftingInfo.GetInfoText()
  self.Total:SetText(text)
  self:SetHeight(16 * lines)
end

function AuctionatorCraftingInfoFrameMixin:SearchButtonClicked()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch()
  else
    print("I would queue a search")
  end
end

function AuctionatorCraftingInfoFrameMixin:OnEvent(...)
  local eventName, paneType = ...
  if paneType == Enum.PlayerInteractionType.Auctioneer then
    self:UpdateSearchButton()
  end
end
