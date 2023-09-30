local owner = {}
local function SelectOwnItem(self)
  ClearCursor()

  local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID())

  if not C_Item.DoesItemExist(itemLocation) then
    return
  end

  local itemLink = C_Item.GetItemLink(itemLocation)

  AuctionatorTabs_Selling:Click()
  Auctionator.EventBus:RegisterSource(owner, "SellingTabBagHooks")
  Auctionator.Groups.CallbackRegistry:RegisterCallback("BagCacheUpdated", function(_, cache)
    Auctionator.Groups.CallbackRegistry:UnregisterCallback("BagCacheUpdated", owner)
    Auctionator.Groups.CallbackRegistry:TriggerEvent("BagCacheOff")
    cache:CacheLinkInfo(itemLink, function()
      local info = Auctionator.Groups.Utilities.ToPostingItem(AuctionatorBagCacheFrame:GetByLinkInstant(itemLink, true))
      if info.location then
        info.location = itemLocation
        Auctionator.EventBus:Fire(owner, Auctionator.Selling.Events.BagItemClicked, info)
      else
        Auctionator.Selling.ShowCannotSellReason(itemLocation)
      end
    end)
  end, owner)
  Auctionator.Groups.CallbackRegistry:TriggerEvent("BagCacheOn")
end

local function AHShown()
  return AuctionFrame and AuctionFrame:IsShown()
end

hooksecurefunc(_G, "ContainerFrameItemButton_OnEnter", function(self)
  if AHShown() and
      Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT) == Auctionator.Config.Shortcuts.RIGHT_CLICK then
    SetAuctionsTabShowing(true)
  end
end)

hooksecurefunc(_G, "ContainerFrameItemButton_OnClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end)

hooksecurefunc(_G, "ContainerFrameItemButton_OnModifiedClick", function(self, button)
  if AHShown() and
      Auctionator.Utilities.IsShortcutActive(Auctionator.Config.Get(Auctionator.Config.Options.SELLING_BAG_SELECT_SHORTCUT), button) then
    SelectOwnItem(self)
  end
end)
