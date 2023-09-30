AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagItemMixin)

function AuctionatorBagItemSelectedMixin:SetItemInfo(info, ...)
  AuctionatorBagItemMixin.SetItemInfo(self, info, ...)
  self.IconSelectedHighlight:Hide()
  self.IconBorder:SetShown(info ~= nil)
  self.Icon:SetAlpha(1)
end

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
  Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_SELLING_TAB, { Auctionator.Utilities.GetNameFromLink(self.itemInfo.itemName)})
end

function AuctionatorBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionatorBagItemSelectedMixin:ProcessCursor()
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  local itemLink = C_Item.GetItemLink(location)

  Auctionator.EventBus:RegisterSource(self, "BagItemSelected")
  Auctionator.Groups.CallbackRegistry:RegisterCallback("BagCacheUpdated", function(_, cache)
    Auctionator.Groups.CallbackRegistry:UnregisterCallback("BagCacheUpdated", self)
    Auctionator.Groups.CallbackRegistry:TriggerEvent("BagCacheOff")
    cache:CacheLinkInfo(itemLink, function()
      local info = Auctionator.Groups.Utilities.ToPostingItem(AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, true))
      if info.location then
        callback(true)
        info.location = location
        Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, info)
      else
        Auctionator.Selling.ShowCannotSellReason(location)
        callback(false)
      end
    end)
  end, self)
  Auctionator.Groups.CallbackRegistry:TriggerEvent("BagCacheOn")
end
