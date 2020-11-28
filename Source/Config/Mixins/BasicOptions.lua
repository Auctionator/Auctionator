AuctionatorConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_BASIC_OPTIONS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigBasicOptionsFrameMixin:OnShow()
  self.Autoscan:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN))
  self.AlternateScan:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.ALTERNATE_SCAN_MODE))
  self.DefaultTab:SetValue(tostring(Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_TAB)))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN, self.Autoscan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.ALTERNATE_SCAN_MODE, self.AlternateScan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_TAB, tonumber(self.DefaultTab:GetValue()))
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end
