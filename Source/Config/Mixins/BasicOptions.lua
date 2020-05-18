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
  self.AuctionChatLog:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  self.AutoListSearch:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH))
  self.UndercutScanPetsGear:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN, self.Autoscan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.ALTERNATE_SCAN_MODE, self.AlternateScan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self.AuctionChatLog:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_SCAN_NOT_LIFO, self.UndercutScanPetsGear:GetChecked())
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end
