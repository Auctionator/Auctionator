AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagItemMixin)

function AuctionatorBagItemSelectedMixin:OnClick(button)
  local wasCursorItem = C_Cursor.GetCursorItem()
  if not self:ProcessCursor() then
    if button == "LeftButton" and not wasCursorItem and self.itemInfo ~= nil then
      self:SearchInShoppingTab()
    else
      AuctionatorBagItemMixin.OnClick(self, button)
    end
  end
end

function AuctionatorBagItemSelectedMixin:SearchInShoppingTab()
  Auctionator.AH.GetItemKeyInfo(self.itemInfo.itemKey, function(itemInfo)
    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_SELLING_TAB, { itemInfo.itemName })
  end)
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
