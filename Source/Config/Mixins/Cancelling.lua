AuctionatorConfigCancellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigCancellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_CANCELLING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigCancellingFrameMixin:OnShow()
  self.UndercutScanPetsGear:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO))
end

function AuctionatorConfigCancellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO, self.UndercutScanPetsGear:GetChecked())
end

function AuctionatorConfigCancellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:Cancel()")
end
