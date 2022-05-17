AuctionatorConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigBasicOptionsFrameMixin:OnShow()
  self.DefaultTab:SetValue(tostring(Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_TAB)))
  self.CraftingCostShowProfit:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_COST_SHOW_PROFIT))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_TAB, tonumber(self.DefaultTab:GetValue()))
  Auctionator.Config.Set(Auctionator.Config.Options.CRAFTING_COST_SHOW_PROFIT, self.CraftingCostShowProfit:GetChecked())
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end
