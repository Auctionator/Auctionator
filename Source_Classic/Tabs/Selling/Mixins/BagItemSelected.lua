AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagItemMixin)

function AuctionatorBagItemSelectedMixin:SetItemInfo(info, ...)
  AuctionatorBagItemMixin.SetItemInfo(self, info, ...)
  self.IconSelectedHighlight:Hide()
  self.IconBorder:SetShown(info ~= nil)
  self.Icon:SetAlpha(1)
end

local seenBag, seenSlot

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
  local item = Item:CreateFromItemLink(self.itemInfo.itemLink)
  item:ContinueOnItemLoad(function()
    Auctionator.API.v1.MultiSearchExact(AUCTIONATOR_L_SELLING_TAB, { item:GetItemName() })
  end)
end

function AuctionatorBagItemSelectedMixin:OnReceiveDrag()
  self:ProcessCursor()
end

function AuctionatorBagItemSelectedMixin:ProcessCursor()
  local location = C_Cursor.GetCursorItem()
  ClearCursor()

  if not location then
    Auctionator.Debug.Message("nothing on cursor")
    return false
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
    return false
  end

  local itemInfo = Auctionator.Utilities.ItemInfoFromLocation(location)
  itemInfo.count = Auctionator.Selling.GetItemCount(location)

  if not Auctionator.EventBus:IsSourceRegistered(self) then
    Auctionator.EventBus:RegisterSource(self, "AuctionatorBagItemSelectedMixin")
  end

  if itemInfo.auctionable then
    Auctionator.Debug.Message("AuctionatorBagItemSelected", "auctionable")
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagItemClicked, itemInfo)
    return true
  end

  Auctionator.Selling.ShowCannotSellReason(itemInfo.location)
  Auctionator.Debug.Message("AuctionatorBagItemSelected", "err")
  return false
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
