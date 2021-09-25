local function GetItemCount(location)
  local locationKey = Auctionator.Selling.UniqueBagKey(Auctionator.Utilities.ItemInfoFromLocation(location))

  local count = 0
  for bagId = 0, 4 do
    for slot = 1, GetContainerNumSlots(bagId) do
      local location = ItemLocation:CreateFromBagAndSlot(bagId, slot)
      if C_Item.DoesItemExist(location) then
        local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)
        local tempId = Auctionator.Selling.UniqueBagKey(itemInfo)
        if tempId == locationKey then
          count = count + itemInfo.count
        end
      end
    end
  end
  return count
end

local function SelectOwnItem(self)
  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());

  if not C_Item.DoesItemExist(itemLocation) or C_Item.IsBound(itemLocation) then
    return
  end

  AuctionatorTabs_Selling:Click()

  local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)
  itemInfo.count = GetItemCount(itemLocation)

  Auctionator.EventBus
    :RegisterSource(self, "ContainerFrameItemButton_On.*Click hook")
    :Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
    :UnregisterSource(self)
end

local function AHShown()
  return AuctionFrame and AuctionFrame:IsShown()
end

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
