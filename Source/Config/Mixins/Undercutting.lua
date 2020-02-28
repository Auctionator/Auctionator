AuctionatorConfigUndercuttingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigUndercuttingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:OnLoad()")

  self.name = "Undercutting"
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigUndercuttingFrameMixin:OnShow()
  self.UndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE))
end

function AuctionatorConfigUndercuttingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_PERCENTAGE, self.UndercutPercentage:GetNumber())
end

function AuctionatorConfigUndercuttingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:Cancel()")
end