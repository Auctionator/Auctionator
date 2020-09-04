AuctionatorConfigShoppingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigShoppingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SHOPPING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigShoppingFrameMixin:OnShow()
  self.AutoListSearch:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH))
end

function AuctionatorConfigShoppingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch:GetChecked())
end

function AuctionatorConfigShoppingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigShoppingFrameMixin:Cancel()")
end
