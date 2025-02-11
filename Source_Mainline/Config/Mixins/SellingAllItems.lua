AuctionatorConfigSellingAllItemsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_ALL_ITEMS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()

  self.ItemSalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigSellingAllItemsFrameMixin:ShowSettings()
  self.currentItemDuration = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION)
  self.currentItemSalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE)

  self.DurationGroup:SetSelectedValue(self.currentItemDuration)
  self.SaveLastDurationAsDefault:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT))
  self.ItemSalesPreference:SetSelectedValue(self.currentItemSalesPreference)

  self:OnSalesPreferenceChange(self.currentItemSalesPreference)

  self.ItemUndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE))
  self.ItemUndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE))

  self.GearPriceMultiplier:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER))
  self.ItemMatching:SetSelectedValue(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ITEM_MATCHING))
end

function AuctionatorConfigSellingAllItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentItemSalesPreference = selectedValue

  if self.currentItemSalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.ItemUndercutPercentage:Show()
    self.ItemUndercutValue:Hide()
  else
    self.ItemUndercutValue:Show()
    self.ItemUndercutPercentage:Hide()
  end
end

function AuctionatorConfigSellingAllItemsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_DURATION, self.DurationGroup:GetValue())
  Auctionator.Config.Set(Auctionator.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT, self.SaveLastDurationAsDefault:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE, self.ItemSalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.ItemUndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE, tonumber(self.ItemUndercutValue:GetAmount()))

  Auctionator.Config.Set(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER, self.GearPriceMultiplier:GetNumber())
  Auctionator.Config.Set(Auctionator.Config.Options.SELLING_ITEM_MATCHING, self.ItemMatching:GetValue())
end

function AuctionatorConfigSellingAllItemsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Cancel()")
end
