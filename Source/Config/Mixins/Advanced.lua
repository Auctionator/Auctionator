AuctionatorConfigAdvancedFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigAdvancedFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_ADVANCED_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigAdvancedFrameMixin:OnShow()
  self.Debug:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.DEBUG))

  self.FullScanStep:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.FULL_SCAN_STEP))
end

function AuctionatorConfigAdvancedFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.DEBUG, self.Debug:GetChecked())

  Auctionator.Config.Set(
    Auctionator.Config.Options.FULL_SCAN_STEP,
    self.FullScanStep:GetNumber()
  )
end

function AuctionatorConfigAdvancedFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigAdvancedFrameMixin:Cancel()")
end
