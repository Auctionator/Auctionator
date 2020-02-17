AuctionatorConfigItemsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigItemsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigItemsFrameMixin:OnLoad()")

  self.name = self:IndentationForSubSection() .. "Items"
  self.parent = "Selling"

  self:SetupPanel()

  self.ItemSalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigItemsFrameMixin:OnShow()
  self.currentItemDuration = Auctionator.Config.Get(Auctionator.Config.Options.ITEM_AUCTION_DURATION)
  self.currentItemSalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.ITEM_AUCTION_SALES_PREFERENCE)

  self.ItemDurationGroup:SetSelectedValue(self.currentItemDuration)
  self.ItemSalesPreference:SetSelectedValue(self.currentItemSalesPreference)

  self:OnSalesPreferenceChange(self.currentItemSalesPreference)

  self.ItemUndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.ITEM_UNDERCUT_PERCENTAGE))
  self.ItemUndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.ITEM_UNDERCUT_STATIC_VALUE))
end

function AuctionatorConfigItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentItemSalesPreference = selectedValue

  if self.currentItemSalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.ItemUndercutPercentage:Show()
    self.ItemUndercutValue:Hide()
  else
    self.ItemUndercutValue:Show()
    self.ItemUndercutPercentage:Hide()
  end
end

function AuctionatorConfigItemsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigItemsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.ITEM_AUCTION_DURATION, self.ItemDurationGroup:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.ITEM_AUCTION_SALES_PREFERENCE, self.ItemSalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.ITEM_UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.ItemUndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.ITEM_UNDERCUT_STATIC_VALUE, tonumber(self.ItemUndercutValue:GetAmount()))
end

function AuctionatorConfigItemsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigItemsFrameMixin:Cancel()")
end