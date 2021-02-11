AuctionatorReagentSearchButtonMixin = {}

function AuctionatorReagentSearchButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  FrameUtil.RegisterFrameForEvents(self, {
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
  })

  hooksecurefunc(TradeSkillFrame, "OnRecipeChanged", function(_, recipeID)
    self:UpdateTotal()
  end)
  hooksecurefunc(TradeSkillFrame.DetailsFrame, "SetSelectedRecipeLevel", function(_, newLevel)
    self:UpdateTotal()
  end)
  Auctionator.API.v1.RegisterForDBUpdate(AUCTIONATOR_L_REAGENT_SEARCH, function()
    if self:IsVisible() then
      self:UpdateTotal()
    end
  end)

  self:ShowWhenAHOpen()
end

function AuctionatorReagentSearchButtonMixin:ShowWhenAHOpen()
  self:SetShown(AuctionHouseFrame ~= nil and AuctionHouseFrame:IsShown())
end

function AuctionatorReagentSearchButtonMixin:UpdateTotal()
  local price = WHITE_FONT_COLOR:WrapTextInColorCode(Auctionator.Utilities.CreateMoneyString(Auctionator.ReagentSearch.GetSkillReagentsTotal()))

  self.Total:SetText(AUCTIONATOR_L_TO_CRAFT_COLON .. " " .. price)
end

function AuctionatorReagentSearchButtonMixin:OnClick()
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
    Auctionator.ReagentSearch.DoTradeSkillReagentsSearch()
  end
end

function AuctionatorReagentSearchButtonMixin:OnEvent(...)
  self:ShowWhenAHOpen()
end
