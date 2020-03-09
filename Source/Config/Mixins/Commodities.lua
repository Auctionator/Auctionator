AuctionatorConfigCommoditiesFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigCommoditiesFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigCommoditiesFrameMixin:OnLoad()")

  self.name = self:IndentationForSubSection() .. "Commodities"
  self.parent = "Selling"

  self:SetupPanel()

  self.CommoditySalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigCommoditiesFrameMixin:OnShow()
  self.currentCommodityDuration = Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_AUCTION_DURATION)
  self.currentCommiditySalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_AUCTION_SALES_PREFERENCE)

  self.CommodityDurationGroup:SetSelectedValue(self.currentCommodityDuration)
  self.CommoditySalesPreference:SetSelectedValue(self.currentCommiditySalesPreference)

  self:OnSalesPreferenceChange(self.currentCommiditySalesPreference)

  self.CommodityUndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_UNDERCUT_PERCENTAGE))
  self.CommodityUndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.COMMODITY_UNDERCUT_STATIC_VALUE))
end

function AuctionatorConfigCommoditiesFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentCommiditySalesPreference = selectedValue

  if self.currentCommiditySalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.CommodityUndercutPercentage:Show()
    self.CommodityUndercutValue:Hide()
  else
    self.CommodityUndercutValue:Show()
    self.CommodityUndercutPercentage:Hide()
  end
end

function AuctionatorConfigCommoditiesFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigCommoditiesFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.COMMODITY_AUCTION_DURATION, self.CommodityDurationGroup:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.COMMODITY_AUCTION_SALES_PREFERENCE, self.CommoditySalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.COMMODITY_UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.CommodityUndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.COMMODITY_UNDERCUT_STATIC_VALUE, self.CommodityUndercutValue:GetAmount())
end

function AuctionatorConfigCommoditiesFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigCommoditiesFrameMixin:Cancel()")
end