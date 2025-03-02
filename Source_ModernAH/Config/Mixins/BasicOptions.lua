AuctionatorConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigBasicOptionsFrameMixin:ShowSettings()
  self.Autoscan:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN))
  self.AutoscanInterval:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN_INTERVAL))
  self.SmallTabs:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SMALL_TABS))
  self.DefaultTab:SetValue(tostring(Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_TAB)))
  self.ShowCraftingInfo:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW))
  self.ShowCraftingCost:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST))
  self.ShowCraftingProfit:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT))
  self.ShowCraftingCheapestQualitiesCost:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.CRAFTING_INFO_SHOW_CHEAPEST_QUALITIES_COST))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN, self.Autoscan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN_INTERVAL, self.AutoscanInterval:GetNumber())
  Auctionator.Config.Set(Auctionator.Config.Options.SMALL_TABS, self.SmallTabs:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_TAB, tonumber(self.DefaultTab:GetValue()))
  Auctionator.Config.Set(Auctionator.Config.Options.CRAFTING_INFO_SHOW, self.ShowCraftingInfo:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.CRAFTING_INFO_SHOW_COST, self.ShowCraftingCost:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.CRAFTING_INFO_SHOW_PROFIT, self.ShowCraftingProfit:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.CRAFTING_INFO_SHOW_CHEAPEST_QUALITIES_COST, self.ShowCraftingCheapestQualitiesCost:GetChecked())
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end
