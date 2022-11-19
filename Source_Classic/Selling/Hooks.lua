local function SelectOwnItem(self)
  ClearCursor()

  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID())

  if not C_Item.DoesItemExist(itemLocation) then
    return
  else
    local currentDurability, maxDurability = GetContainerItemDurability(self:GetParent():GetID(), self:GetID())
    if currentDurability ~= maxDurability then
      UIErrorsFrame:AddMessage(ERR_AUCTION_REPAIR_ITEM, 1.0, 0.1, 0.1, 1.0)
      return
    elseif not Auctionator.Utilities.IsAtMaxCharges(itemLocation) then
      UIErrorsFrame:AddMessage(ERR_AUCTION_USED_CHARGES, 1.0, 0.1, 0.1, 1.0)
      return
    elseif C_Item.IsBound(itemLocation) then
      UIErrorsFrame:AddMessage(ERR_AUCTION_BOUND_ITEM, 1.0, 0.1, 0.1, 1.0)
      return
    end
  end

  AuctionatorTabs_Selling:Click()

  local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)
  itemInfo.count = Auctionator.Selling.GetItemCount(itemLocation)

  Auctionator.EventBus
    :RegisterSource(self, "ContainerFrameItemButton_On.*Click hook")
    :Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
    :UnregisterSource(self)
end

local function AHShown()
  return AuctionFrame and AuctionFrame:IsShown()
end

hooksecurefunc(_G, "ContainerFrameItemButton_OnEnter", function(self)
  if AHShown() and
      Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT) == Auctionator.Config.Shortcuts.RIGHT_CLICK then
    SetAuctionsTabShowing(true)
  end
end)

hooksecurefunc(_G, "ContainerFrameItemButton_OnClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end)

hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end)
