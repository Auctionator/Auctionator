AuctionatorConfigAdvancedFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigAdvancedFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_ADVANCED_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigAdvancedFrameMixin:OnShow()
  self.NotReplicateScan:SetChecked(not Auctionator.Config.Get(Auctionator.Config.Options.REPLICATE_SCAN))
  self.Debug:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.DEBUG))
end

function AuctionatorConfigAdvancedFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.REPLICATE_SCAN, not self.NotReplicateScan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.DEBUG, self.Debug:GetChecked())
end

function AuctionatorConfigAdvancedFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Cancel()")
end
