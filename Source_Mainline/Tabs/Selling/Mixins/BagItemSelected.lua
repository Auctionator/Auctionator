AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagItemMixin)

function AuctionatorBagItemSelectedMixin:OnClick(button)
  if not self:ProcessCursor() then
    AuctionatorBagItemMixin.OnClick(self, button)
  end
end

function AuctionatorBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionatorBagItemSelectedMixin:ProcessCursor()
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  if location and C_AuctionHouse.IsSellItemValid(location, true) then
    local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)
    itemInfo.count = C_AuctionHouse.GetAvailablePostCount(location)

    if not Auctionator.EventBus:IsSourceRegistered(self) then
      Auctionator.EventBus:RegisterSource(self, "AuctionatorBagItemSelectedMixin")
    end
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)

    return true
  end
  return false
end
