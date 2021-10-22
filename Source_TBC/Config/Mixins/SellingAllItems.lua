AuctionatorConfigSellingAllItemsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_ALL_ITEMS_CATEGORY
  self.parent = "Auctionator"

  self:SetupPanel()

  self.SalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigSellingAllItemsFrameMixin:OnShow()
  self.currentDuration = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION)
  self.currentCommiditySalesPreference = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE)

  self.DurationGroup:SetSelectedValue(self.currentDuration)
  self.SalesPreference:SetSelectedValue(self.currentCommiditySalesPreference)

  self:OnSalesPreferenceChange(self.currentCommiditySalesPreference)

  self.UndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE))
  self.UndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE))

  self.GearPriceMultiplier:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER))

  self.StartingPricePercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.STARTING_PRICE_PERCENTAGE))

  local defaultStacks = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_SELLING_STACKS)
  self.DefaultStacks.StackSize:SetNumber(defaultStacks.stackSize)
  self.DefaultStacks.NumStacks:SetNumber(defaultStacks.numStacks)
  self.DefaultStacks:SetMaxStackSize(0)
  self.DefaultStacks:SetMaxNumStacks(0)
  self.DefaultStacks:Show()
end

function AuctionatorConfigSellingAllItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentCommiditySalesPreference = selectedValue

  if self.currentCommiditySalesPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.UndercutPercentage:Show()
    self.UndercutValue:Hide()
  else
    self.UndercutValue:Show()
    self.UndercutPercentage:Hide()
  end
end

function AuctionatorConfigSellingAllItemsFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_DURATION, self.DurationGroup:GetValue())

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE, self.SalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.UndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE, self.UndercutValue:GetAmount())

  Auctionator.Config.Set(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER, self.GearPriceMultiplier:GetNumber())

  Auctionator.Config.Set(
    Auctionator.Config.Options.STARTING_PRICE_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.StartingPricePercentage:GetNumber())
  )

  local defaultStacks = {
    stackSize = self.DefaultStacks.StackSize:GetNumber(),
    numStacks = self.DefaultStacks.NumStacks:GetNumber()
  }
  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_SELLING_STACKS, defaultStacks)
end

function AuctionatorConfigSellingAllItemsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Cancel()")
end
