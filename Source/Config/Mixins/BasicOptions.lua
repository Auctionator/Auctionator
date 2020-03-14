AuctionatorConfigBasicOptionsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigBasicOptionsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:OnLoad()")

  self.name = "Basic Options"
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigBasicOptionsFrameMixin:OnShow()
  self.ShowLists:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_LISTS))
  self.Autoscan:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN))
  self.AuctionChatLog:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  self.AutoListSearch:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUTO_LIST_SEARCH))

  self.Debug:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.DEBUG))
end

function AuctionatorConfigBasicOptionsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_LISTS, self.ShowLists:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTOSCAN, self.Autoscan:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUTO_LIST_SEARCH, self.AutoListSearch:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self.AuctionChatLog:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.DEBUG, self.Debug:GetChecked())
end

function AuctionatorConfigBasicOptionsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigBasicOptionsFrameMixin:Cancel()")
end
