function SB2.DoesSectionExist(name)
  return SB2.Utilities.IsContainedPredicate(AUCTIONATOR_SELLING_GROUPS.CustomSections, function(item) return item.name == name end)
end
function SB2.AddSection(name)
  assert(not SB2.DoesSectionExist(name), "Section already exists")

  table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, {
    name = name,
    type = SB2.Constants.SectionType.List,
    list = {},
    hidden = false,
  })
end

function SB2.GetSectionIndex(name)
  for index, s in ipairs(AUCTIONATOR_SELLING_GROUPS.CustomSections) do
    if s.name == name then
      return index
    end
  end
  return nil
end

function SB2.GetSectionNameByIndex(index)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[index] and AUCTIONATOR_SELLING_GROUPS.CustomSections[index].name
end

function SB2.GetSectionList(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[SB2.GetSectionIndex(name)].list
end

function SB2.IsSectionHidden(name)
  return AUCTIONATOR_SELLING_GROUPS.CustomSections[SB2.GetSectionIndex(name)].hidden
end

function SB2.ToggleSectionHidden(name)
  local section = AUCTIONATOR_SELLING_GROUPS.CustomSections[SB2.GetSectionIndex(name)]
  section.hidden = not section.hidden
end

function SB2.RenameSection(name, newName)
  AUCTIONATOR_SELLING_GROUPS.CustomSections[SB2.GetSectionIndex(name)].name = newName
end

function SB2.DeleteSection(name)
  table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, SB2.GetSectionIndex(name))
end

function SB2.ShiftUpSection(name)
  local index = SB2.GetSectionIndex(name)
  if index > 1 then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomSections[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, index - 1, data)
  end
end

function SB2.ShiftDownSection(name)
  local index = SB2.GetSectionIndex(name)
  if index < #AUCTIONATOR_SELLING_GROUPS.CustomSections then
    local data = AUCTIONATOR_SELLING_GROUPS.CustomSections[index]
    table.remove(AUCTIONATOR_SELLING_GROUPS.CustomSections, index)
    table.insert(AUCTIONATOR_SELLING_GROUPS.CustomSections, index + 1, data)
  end
end
