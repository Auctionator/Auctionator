AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagViewItemMixin)

function AuctionatorBagItemSelectedMixin:SetItemInfo(info, ...)
  AuctionatorBagViewItemMixin.SetItemInfo(self, info, ...)
  self.IconSelectedHighlight:Hide()
  self.IconBorder:SetShown(info ~= nil)
  self.Icon:SetAlpha(1)
end

local seenBag, seenSlot

function AuctionatorBagItemSelectedMixin:OnClick(button)
  local wasCursorItem = C_Cursor.GetCursorItem()
  self:ProcessCursor(function(check)
    if not check then
      if button == "LeftButton" and not wasCursorItem and self.itemInfo ~= nil then
        self:SearchInShoppingTab()
      end
    end
  end)
end

function AuctionatorBagItemSelectedMixin:SearchInShoppingTab()
  Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_SELLING_TAB, { item.itemInfo.itemName })
end

function AuctionatorBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionatorBagItemSelectedMixin:ProcessCursor(callback)
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  if not location then
    Auctionator.Debug.Message("nothing on cursor")
    callback(false)
  end

  -- Case when picking up a key from your keyring, WoW doesn't always give a
  -- valid item location for the cursor, causing an error unless we either:
  --  1. Ignore it
  --  2. Replace the location with one that is valid based on a hook on bag
  --  clicks.
  -- We use 2.
  if not location:HasAnyLocation() then
    Auctionator.Debug.Message("AuctionatorBagItemSelected", "recovering")
    location = ItemLocation:CreateFromBagAndSlot(seenBag, seenSlot)
  end

  if not C_Item.DoesItemExist(location) then
    Auctionator.Debug.Message("AuctionatorBagItemSelected", "not exists")
    callback(false)
  end

  local itemLink = C_Item.GetItemLink(location)

  Auctionator.EventBus:RegisterSource(self, "BagItemSelected")
  Auctionator.BagGroups.CallbackRegistry:RegisterCallback("BagCacheUpdated", function(_, cache)
    Auctionator.BagGroups.CallbackRegistry:UnregisterCallback("BagCacheUpdated", self)
    Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOff")
    cache:CacheLinkInfo(itemLink, function()
      local info = Auctionator.BagGroups.Utilities.ToPostingItem(AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, true))
      if info.location then
        info.location = location
        Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, info)
      else
        Auctionator.Selling.ShowCannotSellReason(location)
      end
      callback(true)
    end)
  end, self)
  Auctionator.BagGroups.CallbackRegistry:TriggerEvent("BagCacheOn")
end

local function HookForPickup(bag, slot)
  seenBag = bag
  seenSlot = slot
end

-- Record clicks on bag items so that we can make keyring items being picked up
-- and placed in the Selling tab work.
if C_Container and C_Container.PickupContainerItem then
  hooksecurefunc(C_Container, "PickupContainerItem", HookForPickup)
else
  hooksecurefunc("PickupContainerItem", HookForPickup)
end
