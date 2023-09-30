function Auctionator.BagGroups.DoesGroupExist(name)
  return Auctionator.BagGroups.Utilities.IsContainedPredicate(AUCTIONATOR_SELLING_GROUPS.CustomGroups, function(item) return item.name == name end)
end
function Auctionator.BagGroups.AddGroup(name)
  assert(not Auctionator.BagGroups.DoesGroupExist(name), "Group already exists")

  table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, {
    name = name,
    type = Auctionator.BagGroups.Constants.GroupType.List,
    list = {},
    hidden = false,
  })
end

function Auctionator.BagGroups.GetGroupIndex(name)
  for index, s in ipairs(AUCTIONATOR_SELLING_GROUPS.CustomGroups) do
    if s.name == name then
      return index
    end
  end
  return nil
end

function Auctionator.BagGroups.GetGroupNameByIndex(index)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[index] and AUCTIONATOR_SELLING_GROUPS.CustomGroups[index].name
end

function Auctionator.BagGroups.GetGroupList(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.BagGroups.GetGroupIndex(name)].list
end

function Auctionator.BagGroups.IsGroupHidden(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.BagGroups.GetGroupIndex(name)].hidden
end

function Auctionator.BagGroups.ToggleGroupHidden(name)
  local group = AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.BagGroups.GetGroupIndex(name)]
  group.hidden = not group.hidden
end

function Auctionator.BagGroups.RenameGroup(name, newName)
  AUCTIONATOR_SELLING_GROUPS.CustomGroups[Auctionator.BagGroups.GetGroupIndex(name)].name = newName
end

function Auctionator.BagGroups.DeleteGroup(name)
  table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, Auctionator.BagGroups.GetGroupIndex(name))
end

function Auctionator.BagGroups.ShiftUpGroup(name)
  local index = Auctionator.BagGroups.GetGroupIndex(name)
  if index > 1 then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomGroups[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index - 1, data)
  end
end

function Auctionator.BagGroups.ShiftDownGroup(name)
  local index = Auctionator.BagGroups.GetGroupIndex(name)
  if index < #AUCTIONATOR_SELLING_GROUPS.CustomGroups then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomGroups[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomGroups, index + 1, data)
  end
end
