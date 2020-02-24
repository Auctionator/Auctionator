AuctionatorConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = "Basic Options"
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigBasicOptionsFrameMixin:OnShow()
  self.MailboxTooltips.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.MAILBOX_TOOLTIPS))
  self.VendorTooltips.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.VENDOR_TOOLTIPS))
  self.AuctionTooltips.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_TOOLTIPS))
  self.EnchantTooltips.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.ENCHANT_TOOLTIPS))
  self.ShiftStackTooltips.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS))

  self.ShowLists.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_LISTS))
  self.Autoscan.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN))
  self.AutoListSearch.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH))

  self.Debug.CheckBox:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.DEBUG))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.MAILBOX_TOOLTIPS, self.MailboxTooltips.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.VENDOR_TOOLTIPS, self.VendorTooltips.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_TOOLTIPS, self.AuctionTooltips.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.ENCHANT_TOOLTIPS, self.EnchantTooltips.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHIFT_STACK_TOOLTIPS, self.ShiftStackTooltips.CheckBox:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_LISTS, self.ShowLists.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN, self.Autoscan.CheckBox:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch.CheckBox:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.DEBUG, self.Debug.CheckBox:GetChecked())
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end