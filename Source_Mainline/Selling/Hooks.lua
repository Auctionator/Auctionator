local function SelectOwnItem(self)
  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());

  if not itemLocation:IsValid() or not C_AuctionHouse.IsSellItemValid(itemLocation) then
    return
  end

  -- Deselect any items in the "Sell" tab
  AuctionHouseFrame.ItemSellFrame:SetItem(nil, nil, false)
  AuctionHouseFrame.CommoditiesSellFrame:SetItem(nil, nil, false)

  AuctionatorTabs_Selling:Click()

  local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)
  itemInfo.count = C_AuctionHouse.GetAvailablePostCount(itemLocation)

  Auctionator.EventBus
    :RegisterSource(self, "ContainerFrameItemButton_OnModifiedClick hook")
    :Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
    :UnregisterSource(self)
end

local function AHShown()
  return AuctionHouseFrame and AuctionHouseFrame:IsShown()
end

hooksecurefunc(_G, "ContainerFrameItemButton_OnClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end)

local function ModifiedClickHook(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end
if ContainerFrameItemButton_OnModifiedClick then
  hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", ModifiedClickHook)
else
  for _, bagID in ipairs(Auctionator.Constants.BagIDs) do
    local index = 1
    local item = _G["ContainerFrame" .. (bagID + 1) .. "Item" .. (index)]
    while item ~= nil do
      hooksecurefunc(item, "OnModifiedClick", ModifiedClickHook)

      index = index + 1
      item = _G["ContainerFrame" .. (bagID + 1) .. "Item" .. (index)]
    end
  end
end
