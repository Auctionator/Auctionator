AuctionatorItemStringLoadingMixin = {}

function AuctionatorItemStringLoadingMixin:OnLoad()
  self:SetOnEntryProcessedCallback(function(entry)
    local item = Item:CreateFromItemID((GetItemInfoInstant(entry.itemString)))
    local complete = false
    item:ContinueOnItemLoad(function()
      -- Check to avoid overwriting name on empty results
      if entry.itemName == nil then
        self:ProcessItemString(entry, { GetItemInfo(entry.itemString) })
      end
      complete = true
    end)
    if complete then
      self:NotifyCacheUsed()
    end
  end)
end

function AuctionatorItemStringLoadingMixin:ProcessItemString(rowEntry, itemInfo)
  local name = itemInfo[Auctionator.Constants.ITEM_INFO.NAME]
  local qualityColor = ITEM_QUALITY_COLORS[itemInfo[Auctionator.Constants.ITEM_INFO.RARITY]].color
  local class = itemInfo[Auctionator.Constants.ITEM_INFO.CLASS]

  rowEntry.itemLink = itemInfo[Auctionator.Constants.ITEM_INFO.LINK]

  rowEntry.name = name
  if class == Enum.ItemClass.Weapon or class == Enum.ItemClass.Armor then
    local itemLevel = GetDetailedItemLevelInfo(rowEntry.itemLink)
    rowEntry.name = rowEntry.name .. " (" .. itemLevel .. ")"
  end
  rowEntry.itemName = qualityColor:WrapTextInColorCode(rowEntry.name)

  rowEntry.iconTexture = itemInfo[Auctionator.Constants.ITEM_INFO.TEXTURE]

  rowEntry.noneAvailable = rowEntry.totalQuantity == 0

  self:SetDirty()
end
