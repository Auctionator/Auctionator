AuctionatorConfigSellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigSellingFrameMixin:OnShow()
  self.AuctionChatLog:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  self.PriceHistory:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY))
  self.BagCollapsed:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED))
  self.AltClick:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ALT_CLICK))
  self.ShiftCancel:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SHIFT_CANCEL))
  self.BagShown:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG))
  self.IconSize:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
end

function AuctionatorConfigSellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self.AuctionChatLog:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY, self.PriceHistory:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_COLLAPSED, self.BagCollapsed:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ALT_CLICK, self.AltClick:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_SHIFT_CANCEL, self.ShiftCancel:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ICON_SIZE, math.min(50, math.max(10, self.IconSize:GetNumber())))
end

function AuctionatorConfigSellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Cancel()")
end
