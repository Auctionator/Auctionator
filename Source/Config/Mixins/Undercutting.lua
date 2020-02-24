AuctionatorConfigUndercuttingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigUndercuttingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:OnLoad()")

  self.name = "Undercutting"
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigUndercuttingFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:OnShow()")
end

function AuctionatorConfigUndercuttingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:Save()")
end

function AuctionatorConfigUndercuttingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigUndercuttingFrameMixin:Cancel()")
end