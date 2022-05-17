AuctionatorConfigCancellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigCancellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_CANCELLING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigCancellingFrameMixin:OnShow()
  self.CancelUndercutShortcut:SetShortcut(Auctionator.Config.Get(Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT))
end

function AuctionatorConfigCancellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.CANCEL_UNDERCUT_SHORTCUT, self.CancelUndercutShortcut:GetShortcut())
end

function AuctionatorConfigCancellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigCancellingFrameMixin:Cancel()")
end
