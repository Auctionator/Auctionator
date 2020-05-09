AuctionatorConfigAdvancedFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigAdvancedFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_ADVANCED_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigAdvancedFrameMixin:OnShow()
  self.FullScanSpeed:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.FULL_SCAN_SPEED))
end

function AuctionatorConfigAdvancedFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Save()")

  Auctionator.Config.Set(
    Auctionator.Config.Options.FULL_SCAN_SPEED,
    self.FullScanSpeed:GetNumber()
  )
end

function AuctionatorConfigAdvancedFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Cancel()")
end
