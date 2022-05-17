AuctionatorConfigSellingShortcutsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingShortcutsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingShortcutsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_SHORTCUTS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigSellingShortcutsFrameMixin:OnShow()
  self.BagSelectShortcut:SetValue(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT))

  self.PostShortcut:SetShortcut(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_POST_SHORTCUT))
  self.SkipShortcut:SetShortcut(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SKIP_SHORTCUT))
end

function AuctionatorConfigSellingShortcutsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingShortcutsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT, self.BagSelectShortcut:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_POST_SHORTCUT, self.PostShortcut:GetShortcut())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_SKIP_SHORTCUT, self.SkipShortcut:GetShortcut())
end

function AuctionatorConfigSellingShortcutsFrameMixin:UnhideAllClicked()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})
  self.UnhideAll:Disable()
end

function AuctionatorConfigSellingShortcutsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingShortcutsFrameMixin:Cancel()")
end
