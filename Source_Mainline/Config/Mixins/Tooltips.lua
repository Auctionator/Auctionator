AuctionatorConfigTooltipsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigTooltipsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_TOOLTIPS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigTooltipsFrameMixin:ShowSettings()
  self.MailboxTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.MAILBOX_TOOLTIPS))
  self.PetTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.PET_TOOLTIPS))
  self.VendorTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.VENDOR_TOOLTIPS))
  self.AuctionTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS))
  self.EnchantTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.ENCHANT_TOOLTIPS))
  self.ShiftStackTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS))
  self.AuctionAgeTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_AGE_TOOLTIPS))
end

function AuctionatorConfigTooltipsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.MAILBOX_TOOLTIPS, self.MailboxTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.PET_TOOLTIPS, self.PetTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.VENDOR_TOOLTIPS, self.VendorTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_TOOLTIPS, self.AuctionTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.ENCHANT_TOOLTIPS, self.EnchantTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS, self.ShiftStackTooltips:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_AGE_TOOLTIPS, self.AuctionAgeTooltips:GetChecked())
end

function AuctionatorConfigTooltipsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:Cancel()")
end
