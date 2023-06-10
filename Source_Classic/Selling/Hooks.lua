local function SelectOwnItem(self)
  ClearCursor()

  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID())

  if not C_Item.DoesItemExist(itemLocation) then
    return
  end

  local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)

  if not itemInfo.auctionable then
    Auctionator.Selling.ShowCannotSellReason(itemLocation)
    return
  end

  AuctionatorTabs_Selling:Click()
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
