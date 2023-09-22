local function SelectOwnItem(itemLocation)
  if not itemLocation:IsValid() or not C_AuctionHouse.IsSellItemValid(itemLocation) then
    return
  end

  -- Deselect any items in the "Sell" tab
  AuctionHouseFrame.ItemSellFrame:SetItem(nil, nil, false)
  AuctionHouseFrame.CommoditiesSellFrame:SetItem(nil, nil, false)

  AuctionatorTabs_Selling:Click()

  local itemLink = C_Item.GetItemLink(itemLocation)
  SB2BagCacheFrame:CacheLinkInfo(itemLink, function()
    local itemInfo = SB2BagCacheFrame:GetByLinkInstant(itemLink)
    Auctionator.EventBus:RegisterSource(SelectOwnItem, "SellingItemClickedHook")
    ---XXX Remove this
    Auctionator.EventBus:Fire(SelectOwnItem, Auctionator.Selling.Events.BagItemClicked, {
      itemLink = itemInfo.itemLink,
      itemID = itemInfo.itemID,
      itemName = itemInfo.itemName,
      itemLevel = itemInfo.itemLevel,
      iconTexture = itemInfo.iconTexture,
      quality = itemInfo.quality,
      count = C_AuctionHouse.GetAvailablePostCount(itemLocation),
      location = itemLocation,
      classId = itemInfo.classID,
      auctionable = true,
      bagListing = true,
    })
  end)
end

local function AHShown()
  return AuctionHouseFrame and AuctionHouseFrame:IsShown()
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
