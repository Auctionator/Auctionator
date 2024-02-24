local function SelectOwnItem(itemLocation)
  if not itemLocation:IsValid() or not C_AuctionHouse.IsSellItemValid(itemLocation) then
    return
  end

  -- Deselect any items in the "Sell" tab
  AuctionHouseFrame.ItemSellFrame:SetItem(nil, nil, false)
  AuctionHouseFrame.CommoditiesSellFrame:SetItem(nil, nil, false)

  AuctionatorTabs_Selling:Click()

  local itemLink = C_Item.GetItemLink(itemLocation)
  AuctionatorBagCacheFrame:CacheLinkInfo(itemLink, function()
    local info = Auctionator.Groups.Utilities.ToPostingItem(AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, true))
    info.itemLink = itemLink
    info.location = itemLocation
    info.count = C_AuctionHouse.GetAvailablePostCount(itemLocation)
    Auctionator.EventBus:RegisterSource(SelectOwnItem, "SellingItemClickedHook")
    Auctionator.EventBus:Fire(SelectOwnItem, Auctionator.Selling.Events.BagItemClicked, info)
  end)
end

local function AHShown()
  return AuctionHouseFrame and AuctionHouseFrame:IsShown() and AuctionatorTabs_Selling
end

hooksecurefunc(_G, "ContainerFrameItemButton_OnClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
    SelectOwnItem(itemLocation)
  end
end)

hooksecurefunc(_G, "HandleModifiedItemClick", function(itemLink, itemLocation)
  if itemLocation ~= nil and AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), GetMouseButtonClicked()) then
    SelectOwnItem(itemLocation)
  end
end)
