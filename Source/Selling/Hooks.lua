hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", function(self, button)
  if (Auctionator.Config.Get(Auctionator.Config.Options.SELLING_ALT_CLICK) and 
      AuctionHouseFrame and AuctionHouseFrame:IsShown() and IsAltKeyDown() and button == "LeftButton") then
    AuctionatorTabs_Selling:Click()

    local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());

    if not C_AuctionHouse.IsSellItemValid(itemLocation) then
      return
    end

    local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(itemLocation)
    itemInfo.count = C_AuctionHouse.GetAvailablePostCount(itemLocation)

    Auctionator.EventBus
      :RegisterSource(self, "ContainerFrameItemButton_OnModifiedClick hook")
      :Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
      :UnregisterSource(self)
  end
end)
