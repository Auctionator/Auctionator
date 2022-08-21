AuctionatorConfigSellingAllItemsFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_CONFIG_SELLING_ALL_ITEMS_CATEGORY
  self.parent = "Auctionator"
  self.beenShown = false

  self:SetupPanel()

  self.SalesPreference:SetOnChange(function(selectedValue)
    self:OnSalesPreferenceChange(selectedValue)
  end)
end

function AuctionatorConfigSellingAllItemsFrameMixin:OnShow()
  self.beenShown = true
  self.currentUndercutPreference = Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE)

  self.DurationGroup:SetSelectedValue(Auctionator.Config.Get(Auctionator.Config.Options.AUCTION_DURATION))
  self.SaveLastDurationAsDefault:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT))
  self.SalesPreference:SetSelectedValue(self.currentUndercutPreference)

  self:OnSalesPreferenceChange(self.currentUndercutPreference)

  self.UndercutPercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_PERCENTAGE))
  self.UndercutValue:SetAmount(Auctionator.Config.Get(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE))

  self.GearPriceMultiplier:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER))

  self.StartingPricePercentage:SetNumber(Auctionator.Config.Get(Auctionator.Config.Options.STARTING_PRICE_PERCENTAGE))

  local defaultStacks = Auctionator.Config.Get(Auctionator.Config.Options.DEFAULT_SELLING_STACKS)
  self.DefaultStacks.StackSize:SetNumber(defaultStacks.stackSize)
  self.DefaultStacks.NumStacks:SetNumber(defaultStacks.numStacks)
  self.DefaultStacks.StackSize:Show()
  self.DefaultStacks.NumStacks:Show()
  self.DefaultStacks:SetMaxStackSize(0)
  self.DefaultStacks:SetMaxNumStacks(0)

  self.ResetStackSizeMemory:SetEnabled(next(Auctionator.Config.Get(Auctionator.Config.Options.STACK_SIZE_MEMORY)) ~= nil)
end

function AuctionatorConfigSellingAllItemsFrameMixin:OnSalesPreferenceChange(selectedValue)
  self.currentUndercutPreference = selectedValue

  if self.currentUndercutPreference == Auctionator.Config.SalesTypes.PERCENTAGE then
    self.UndercutPercentage:Show()
    self.UndercutValue:Hide()
  else
    self.UndercutValue:Show()
    self.UndercutPercentage:Hide()
  end
end

function AuctionatorConfigSellingAllItemsFrameMixin:Save()
  if not self.beenShown then
    return
  end

  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Save()")

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_DURATION, self.DurationGroup:GetValue())
  Auctionator.Config.Set(Auctionator.Config.Options.SAVE_LAST_DURATION_AS_DEFAULT, self.SaveLastDurationAsDefault:GetChecked())

  Auctionator.Config.Set(Auctionator.Config.Options.AUCTION_SALES_PREFERENCE, self.SalesPreference:GetValue())
  Auctionator.Config.Set(
    Auctionator.Config.Options.UNDERCUT_PERCENTAGE,
    Auctionator.Utilities.ValidatePercentage(self.UndercutPercentage:GetNumber())
  )
  Auctionator.Config.Set(Auctionator.Config.Options.UNDERCUT_STATIC_VALUE, self.UndercutValue:GetAmount())

  Auctionator.Config.Set(Auctionator.Config.Options.GEAR_PRICE_MULTIPLIER, self.GearPriceMultiplier:GetNumber())

  local newPercentage = Auctionator.Utilities.ValidatePercentage(self.StartingPricePercentage:GetNumber())
  if newPercentage > 0 then
    Auctionator.Config.Set(
      Auctionator.Config.Options.STARTING_PRICE_PERCENTAGE,
      newPercentage
    )
  end

  local defaultStacks = {
    stackSize = self.DefaultStacks.StackSize:GetNumber(),
    numStacks = self.DefaultStacks.NumStacks:GetNumber()
  }
  Auctionator.Config.Set(Auctionator.Config.Options.DEFAULT_SELLING_STACKS, defaultStacks)
end

function AuctionatorConfigSellingAllItemsFrameMixin:ResetStackSizeMemoryClicked()
  Auctionator.Config.Set(Auctionator.Config.Options.STACK_SIZE_MEMORY, {})
  self.ResetStackSizeMemory:Disable()
end

function AuctionatorConfigSellingAllItemsFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigSellingAllItemsFrameMixin:Cancel()")
end
