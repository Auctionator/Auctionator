function Auctionator.BagGroups.DoesSectionExist(name)
  return Auctionator.BagGroups.Utilities.IsContainedPredicate(AUCTIONATOR_SELLING_GROUPS.CustomSections, function(item) return item.name == name end)
end
function Auctionator.BagGroups.AddSection(name)
  assert(not Auctionator.BagGroups.DoesSectionExist(name), "Section already exists")

  table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, {
    name = name,
    type = Auctionator.BagGroups.Constants.SectionType.List,
    list = {},
    hidden = false,
  })
end

function Auctionator.BagGroups.GetSectionIndex(name)
  for index, s in ipairs(AUCTIONATOR_SELLING_GROUPS.CustomSections) do
    if s.name == name then
      return index
    end
  end
  return nil
end

function Auctionator.BagGroups.GetSectionNameByIndex(index)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[index] and AUCTIONATOR_SELLING_GROUPS.CustomSections[index].name
end

function Auctionator.BagGroups.GetSectionList(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[Auctionator.BagGroups.GetSectionIndex(name)].list
end

function Auctionator.BagGroups.IsSectionHidden(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[Auctionator.BagGroups.GetSectionIndex(name)].hidden
end

function Auctionator.BagGroups.ToggleSectionHidden(name)
  local section = AUCTIONATOR_SELLING_GROUPS.CustomSections[Auctionator.BagGroups.GetSectionIndex(name)]
  section.hidden = not section.hidden
end

function Auctionator.BagGroups.RenameSection(name, newName)
  AUCTIONATOR_SELLING_GROUPS.CustomSections[Auctionator.BagGroups.GetSectionIndex(name)].name = newName
end

function Auctionator.BagGroups.DeleteSection(name)
  table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, Auctionator.BagGroups.GetSectionIndex(name))
end

function Auctionator.BagGroups.ShiftUpSection(name)
  local index = Auctionator.BagGroups.GetSectionIndex(name)
  if index > 1 then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomSections[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, index - 1, data)
  end
end

function Auctionator.BagGroups.ShiftDownSection(name)
  local index = Auctionator.BagGroups.GetSectionIndex(name)
  if index < #AUCTIONATOR_SELLING_GROUPS.CustomSections then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomSections[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, index + 1, data)
  end
end
