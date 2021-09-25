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

  if location then
    local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)

    if not Auctionator.EventBus:IsSourceRegistered(self) then
      Auctionator.EventBus:RegisterSource(self, "AuctionatorBagItemSelectedMixin")
    end

    if itemInfo.auctionable then
      Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
      return true
    end
  end
  return false
end
