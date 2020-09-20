AuctionatorConfigLIFOFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigLIFOFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigLIFOFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_LIFO_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()

  self.CommoditySalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigLIFOFrameMixin:OnShow()
  self.currentCommodityDuration = Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_DURATION)
  self.currentCommiditySalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.LIFO_AUCTION_SALES_PREFERENCE)

  self.CommodityDurationGroup:SetSelectedValue(self.currentCommodityDuration)
  self.CommoditySalesPreference:SetSelectedValue(self.currentCommiditySalesPreference)

  self:OnSalesPreferenceChange(self.currentCommiditySalesPreference)

  self.CommodityUndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.LIFO_UNDERCUT_PERCENTAGE))
  self.CommodityUndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.LIFO_UNDERCUT_STATIC_VALUE))

  self.DefaultQuantity:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.LIFO_DEFAULT_QUANTITY))
end

function AuctionatorConfigLIFOFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentCommiditySalesPreference = selectedValue

  if self.currentCommiditySalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.CommodityUndercutPercentage:Show()
    self.CommodityUndercutValue:Hide()
  else
    self.CommodityUndercutValue:Show()
    self.CommodityUndercutPercentage:Hide()
  end
end

function AuctionatorConfigLIFOFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigLIFOFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.LIFO_AUCTION_DURATION, self.CommodityDurationGroup:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.LIFO_AUCTION_SALES_PREFERENCE, self.CommoditySalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.LIFO_UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.CommodityUndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.LIFO_UNDERCUT_STATIC_VALUE, self.CommodityUndercutValue:GetAmount())

  Auctionator.Config.Set(Auctionator.Config.Options.LIFO_DEFAULT_QUANTITY, self.DefaultQuantity:GetNumber())
end

function AuctionatorConfigLIFOFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigLIFOFrameMixin:Cancel()")
end
