AuctionatorConfigProfileFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigProfileFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigProfileFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_PROFILE_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigProfileFrameMixin:ShowSettings()
  self.ProfileToggle:SetChecked(Auctionator.Config.IsCharacterConfig())
end

function AuctionatorConfigProfileFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigProfileFrameMixin:Save()")

  Auctionator.Config.SetCharacterConfig(self.ProfileToggle:GetChecked())
end

function AuctionatorConfigProfileFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigProfileFrameMixin:Cancel()")
end
