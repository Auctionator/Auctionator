AuctionatorBagItemSelectedMixin = CreateFromMixins(AuctionatorBagItemMixin)

local seenBag, seenSlot

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

  Auctionator.Debug.Message("AuctionatorBagItemSelected", "err")
  UIErrorsFrame:AddMessage(ERR_AUCTION_BOUND_ITEM, 1.0, 0.1, 0.1, 1.0)
  return false
end

-- Record clicks on bag items so that we can make keyring items being picked up
-- and placed in the Selling tab work.
hooksecurefunc("PickupContainerItem", function(bag, slot)
  seenBag = bag
  seenSlot = slot
end)
