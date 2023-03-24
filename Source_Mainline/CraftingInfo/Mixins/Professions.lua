AuctionatorCraftingInfoProfessionsFrameMixin = {}

function AuctionatorCraftingInfoProfessionsFrameMixin:OnLoad()
  FrameUtil.RegisterFrameForEvents(self, {
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
  })
  self:UpdateSearchButton()

  local function Update()
    self:ShowIfRelevant()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end

  -- Uses Init rather than an event as the event handler can fire before the
  -- ProfessionsPane pane has finished initialising a recipe
  hooksecurefunc(self:GetParent(), "Init", Update)

  self:GetParent():RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, Update)
  self:GetParent():RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, Update)

  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)
end

function AuctionatorCraftingInfoProfessionsFrameMixin:SetDoNotShowProfit()
  self.doNotShowProfit = true
end

function AuctionatorCraftingInfoProfessionsFrameMixin:ShowIfRelevant()
  self:SetShown(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW) and self:GetParent():GetRecipeInfo() ~= nil and self:IsAnyReagents())

  if self:IsVisible() then
    self:ClearAllPoints()

    local reagents = self:GetParent().Reagents
    local framesToBeBelow = {
      self:GetParent().OptionalReagents,
    }
    for _, f in ipairs(self:GetParent().extraSlotFrames) do
      table.insert(framesToBeBelow, f)
    end
    local min = reagents
    for _, f in ipairs(framesToBeBelow) do
      if f:IsShown() and f:GetBottom() < min:GetBottom() then
        min = f
      end
    end

    self:SetPoint("LEFT", reagents, "LEFT", 0, -10)

    self:SetPoint("TOP", min, "BOTTOM", 0, -5)

    self:UpdateSearchButton()
  end
end

function AuctionatorCraftingInfoProfessionsFrameMixin:UpdateSearchButton()
  self.SearchButton:SetShown(AuctionHouseFrame and AuctionHouseFrame:IsShown())
end

-- Checks for case when there are no regeants, for example a DK Runeforging
-- crafting view.
function AuctionatorCraftingInfoProfessionsFrameMixin:IsAnyReagents()
  local schematicForm = self:GetParent()
  local recipeInfo = schematicForm:GetRecipeInfo()
  local recipeID = recipeInfo.recipeID
  local recipeLevel = schematicForm:GetCurrentRecipeLevel()
  local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, false, recipeLevel)
  return #recipeSchematic.reagentSlotSchematics > 0
end

function AuctionatorCraftingInfoProfessionsFrameMixin:UpdateTotal()
  local text, lines = Auctionator.CraftingInfo.GetInfoText(self:GetParent(), not self.doNotShowProfit)
  self.Total:SetText(text)
  self:SetHeight(16 * lines)
end

function AuctionatorCraftingInfoProfessionsFrameMixin:SearchButtonClicked()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.CraftingInfo.DoTradeSkillReagentsSearch(self:GetParent())
  else
    print("I would queue a search")
  end
end

function AuctionatorCraftingInfoProfessionsFrameMixin:OnEvent(...)
  local eventName, paneType = ...
  if paneType == Enum.PlayerInteractionType.Auctioneer then
    self:UpdateSearchButton()
  end
end
