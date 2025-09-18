AuctionatorConfigTooltipsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigTooltipsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_TOOLTIPS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()

  if not Auctionator.Constants.IsRetail then
    self.EnchantTooltips:SetText(AUCTIONATOR_L_CONFIG_ENCHANT_GENERIC_TOOLTIP)
    self.ProspectTooltips:Show()
    self.MillTooltips:Show()
    self.AuctionAgeTooltips:SetPoint("TOPLEFT", self.MillTooltips, "BOTTOMLEFT")
  end
end

function AuctionatorConfigTooltipsFrameMixin:ShowSettings()
  self.MailboxTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.MAILBOX_TOOLTIPS))
  self.PetTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.PET_TOOLTIPS))
  self.VendorTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.VENDOR_TOOLTIPS))
  self.AuctionTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS))
  self.EnchantTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.ENCHANT_TOOLTIPS))
  self.ShiftStackTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS))
  self.AuctionAgeTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_AGE_TOOLTIPS))

  if not Auctionator.Constants.IsRetail then
    self.ProspectTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.PROSPECT_TOOLTIPS))
    self.MillTooltips:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.MILL_TOOLTIPS))
  end
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

  if not Auctionator.Constants.IsRetail then
    Auctionator.Config.Set(Auctionator.Config.Options.PROSPECT_TOOLTIPS, self.ProspectTooltips:GetChecked())
    Auctionator.Config.Set(Auctionator.Config.Options.MILL_TOOLTIPS, self.MillTooltips:GetChecked())
  end
end

function AuctionatorConfigTooltipsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigTooltipsFrameMixin:Cancel()")
end
