function Auctionator.Groups.DoesGroupExist(name)
  return Auctionator.Groups.Utilities.IsContainedPredicate(AUCTIONATOR_SELLING_GROUPS.CustomGroups, function(item) return item.name == name end)
end
function Auctionator.Groups.AddGroup(name)
  assert(not Auctionator.Groups.DoesGroupExist(name), "Group already exists")

  table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, {
    name = name,
    type = Auctionator.Groups.Constants.GroupType.List,
    list = {},
    hidden = false,
  })
end

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

function Auctionator.Groups.IsGroupHidden(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.Groups.GetGroupIndex(name)].hidden
end

function Auctionator.Groups.ToggleGroupHidden(name)
  local group = AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.Groups.GetGroupIndex(name)]
  group.hidden = not group.hidden
end

function Auctionator.Groups.RenameGroup(name, newName)
  AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.Groups.GetGroupIndex(name)].name = newName
end

function Auctionator.Groups.DeleteGroup(name)
  table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, Auctionator.Groups.GetGroupIndex(name))
end

function Auctionator.Groups.ShiftUpGroup(name)
  local index = Auctionator.Groups.GetGroupIndex(name)
  if index > 1 then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomGroups[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index - 1, data)
  end
end

function Auctionator.Groups.ShiftDownGroup(name)
  local index = Auctionator.Groups.GetGroupIndex(name)
  if index < #AUCTIONATOR_SELLING_GROUPS.CustomGroups then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomGroups[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index + 1, data)
  end
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

function Auctionator.Groups.GetHiddenItemLinks()
  return AUCTIONATOR_SELLING_GROUPS.HiddenItems
end
