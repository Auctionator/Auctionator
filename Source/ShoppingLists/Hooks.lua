local function SearchOwnItem(self)
  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());

  if not C_Item.DoesItemExist(itemLocation) then
    return
  end

  if StackSplitFrame ~= nil and StackSplitFrame:IsVisible() then
    StackSplitFrame:Hide()
  end

  local itemLink = select(7, GetContainerItemInfo(itemLocation:GetBagAndSlot()))
  local name = Auctionator.Utilities.GetNameFromLink(itemLink)

  AuctionatorShoppingListFrame.OneItemSearchBox:SetText(name)
  AuctionatorShoppingListFrame.OneItemSearchButton:Click()
end

-- The bag item button is hooked so that we can hide the stack split frame when
-- it appears, otherwise hooking ChatEdit_InsertLink would be enough.
hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", function(self, button)
  if AuctionatorShoppingListFrame ~= nil and AuctionatorShoppingListFrame:IsVisible() and Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Shortcuts.SHIFT_LEFT_CLICK, button) then
    SearchOwnItem(self)
  end
end)
