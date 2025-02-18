AuctionatorConfigSellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()
end

function AuctionatorConfigSellingFrameMixin:ShowSettings()
  self.AuctionChatLog:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  self.ShowBidPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE))
  self.ConfirmPostLowPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE))
  self.SplitPanels:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SPLIT_PANELS))

  self.BagShown:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG))
  self.IconSize:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  self.BagCollapsed:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED))
  self.AutoSelectNext:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT))
  self.ReselectItem:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SHOULD_RESELECT_ITEM))
  self.MissingFavourites:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES))
  self.PossessedFavouritesFirst:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED))

  self.UnhideAll:SetEnabled(#(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS)) ~= 0)
end

function AuctionatorConfigSellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self.AuctionChatLog:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE, self.ShowBidPrice:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE, self.ConfirmPostLowPrice:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_SPLIT_PANELS, self.SplitPanels:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_BAG, self.BagShown:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ICON_SIZE, math.min(50, math.max(10, self.IconSize:GetNumber())))
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_COLLAPSED, self.BagCollapsed:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT, self.AutoSelectNext:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_SHOULD_RESELECT_ITEM, self.ReselectItem:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES, self.MissingFavourites:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED, self.PossessedFavouritesFirst:GetChecked())
end

function AuctionatorConfigSellingFrameMixin:UnhideAllClicked()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})
  self.UnhideAll:Disable()
end

function AuctionatorConfigSellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Cancel()")
end
