hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", function(self, button)
  if AuctionHouseFrame and AuctionHouseFrame:IsShown() and IsAltKeyDown() then
    AuctionatorTabs_Selling:Click()

    local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
    local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)
    itemInfo.count = C_AuctionHouse.GetAvailablePostCount(itemLocation)

    Auctionator.EventBus
      :RegisterSource(self, "ContainerFrameItemButton_OnModifiedClick hook")
      :Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
      :UnregisterSource(self)
  end
end)
