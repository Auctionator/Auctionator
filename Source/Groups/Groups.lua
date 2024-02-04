function Auctionator.Groups.GetGroupIndex(name)
  for index, s in ipairs(AUCTIONATOR_SELLING_GROUPS.CustomGroups) do
    if s.name == name then
      return index
    end
  end
  return nil
end

function Auctionator.Groups.GetGroupNameByIndex(index)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[index] and AUCTIONATOR_SELLING_GROUPS.CustomGroups[index].name
end

function Auctionator.Groups.GetGroupList(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.Groups.GetGroupIndex(name)].list
end

function Auctionator.Groups.HideItemLink(itemLink)
  table.insert(AUCTIONATOR_SELLING_GROUPS.HiddenItems, itemLink)
end

function Auctionator.Groups.UnhideItemLink(itemLink)
  local index = tIndexOf(AUCTIONATOR_SELLING_GROUPS.HiddenItems, itemLink)
  if index ~= nil then
    table.remove(AUCTIONATOR_SELLING_GROUPS.HiddenItems, index)
  end
end

function Auctionator.Groups.UnhideAll()
  AUCTIONATOR_SELLING_GROUPS.HiddenItems = {}
end
