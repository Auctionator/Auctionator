AuctionatorConfigSellingFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_CATEGORY
  self.parent = "Auctionator"

  local view = CreateScrollBoxLinearView()
  view:SetPadding(0, 25, 10, 10, 0)
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);
  self.ScrollBox.Content.OnCleaned = function() self.ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately) end
  self.ScrollBox.Content:MarkDirty()

  self:SetupPanel()
end

function AuctionatorConfigSellingFrameMixin:ShowSettings()
  self.ScrollBox.Content.AuctionChatLog:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_CHAT_LOG))
  self.ScrollBox.Content.ShowBidPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE))
  self.ScrollBox.Content.BagCollapsed:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_COLLAPSED))
  self.ScrollBox.Content.ConfirmPostLowPrice:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE))
  self.ScrollBox.Content.AlwaysLoadMore:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ALWAYS_LOAD_MORE))
  self.ScrollBox.Content.GreyPostButton:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_GREY_POST_BUTTON))

  self.ScrollBox.Content.BagShown:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_BAG))
  self.ScrollBox.Content.IconSize:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ICON_SIZE))
  self.ScrollBox.Content.AutoSelectNext:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT))
  self.ScrollBox.Content.AutoSelectStackRemainder:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_POST_STACK_REMAINDER))
  self.ScrollBox.Content.ReselectItem:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_SHOULD_RESELECT_ITEM))
  self.ScrollBox.Content.MissingFavourites:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES))
  self.ScrollBox.Content.PossessedFavouritesFirst:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED))

  self.ScrollBox.Content.UnhideAll:SetEnabled(#(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_IGNORED_KEYS)) ~= 0)
  self:UpdateSellingSelectionColor()
end

function AuctionatorConfigSellingFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_CHAT_LOG, self.ScrollBox.Content.AuctionChatLog:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_BID_PRICE, self.ScrollBox.Content.ShowBidPrice:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_COLLAPSED, self.ScrollBox.Content.BagCollapsed:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_CONFIRM_LOW_PRICE, self.ScrollBox.Content.ConfirmPostLowPrice:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ALWAYS_LOAD_MORE, self.ScrollBox.Content.AlwaysLoadMore:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_GREY_POST_BUTTON, self.ScrollBox.Content.GreyPostButton:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.SHOW_SELLING_BAG, self.ScrollBox.Content.BagShown:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ICON_SIZE, math.min(50, math.max(10, self.ScrollBox.Content.IconSize:GetNumber())))
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_AUTO_SELECT_NEXT, self.ScrollBox.Content.AutoSelectNext:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_POST_STACK_REMAINDER, self.ScrollBox.Content.AutoSelectStackRemainder:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_SHOULD_RESELECT_ITEM, self.ScrollBox.Content.ReselectItem:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_MISSING_FAVOURITES, self.ScrollBox.Content.MissingFavourites:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_FAVOURITES_SORT_OWNED, self.ScrollBox.Content.PossessedFavouritesFirst:GetChecked())
end

function AuctionatorConfigSellingFrameMixin:UpdateSellingSelectionColor()
  local color = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR)
  self.ScrollBox.Content.SetSelectionColor.Color:SetColorTexture(color.r, color.g, color.b)
end

function AuctionatorConfigSellingFrameMixin:UnhideAllClicked()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})
  self.ScrollBox.Content.UnhideAll:Disable()
end

function AuctionatorConfigSellingFrameMixin:ResetSelectionColorClicked()
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR, Auctionator.Config.Defaults[Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR])
  self:UpdateSellingSelectionColor()
end

function AuctionatorConfigSellingFrameMixin:SetSelectionColorClicked()
  ShowUIPanel(ColorPickerFrame)
  local color = Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR)
  ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
  ColorPickerFrame.func = function()
    local r, g, b = ColorPickerFrame:GetColorRGB()
    Auctionator.Config.Set(Auctionator.Config.Options.SELLING_BAG_SELECTION_COLOR, {r = r, g = g, b = b})
    self:UpdateSellingSelectionColor()
  end
end

function AuctionatorConfigSellingFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingFrameMixin:Cancel()")
end
