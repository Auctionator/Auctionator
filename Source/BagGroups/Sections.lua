function SB2.DoesSectionExist(name)
  return SB2.Utilities.IsContainedPredicate(SB2_BAG_SETUP.CustomSections, function(item) return item.name == name end)
end
function SB2.AddSection(name)
  assert(not SB2.DoesSectionExist(name), "Section already exists")

  table.insert(SB2_BAG_SETUP.CustomSections, {
    name = name,
    type = SB2.Constants.SectionType.List,
    list = {},
    hidden = false,
  })
end

function SB2.GetSectionIndex(name)
  for index, s in ipairs(SB2_BAG_SETUP.CustomSections) do
    if s.name == name then
      return index
    end
  end
  return nil
end

function SB2.GetSectionNameByIndex(index)
  return SB2_BAG_SETUP.CustomSections[index] and SB2_BAG_SETUP.CustomSections[index].name
end

function SB2.GetSectionList(name)
  return SB2_BAG_SETUP.CustomSections[SB2.GetSectionIndex(name)].list
end

function SB2.IsSectionHidden(name)
  return SB2_BAG_SETUP.CustomSections[SB2.GetSectionIndex(name)].hidden
end

function SB2.ToggleSectionHidden(name)
  local section = SB2_BAG_SETUP.CustomSections[SB2.GetSectionIndex(name)]
  section.hidden = not section.hidden
end

function SB2.RenameSection(name, newName)
  SB2_BAG_SETUP.CustomSections[SB2.GetSectionIndex(name)].name = newName
end

function SB2.DeleteSection(name)
  table.remove(SB2_BAG_SETUP.CustomSections, SB2.GetSectionIndex(name))
end

function SB2.ShiftUpSection(name)
  local index = SB2.GetSectionIndex(name)
  if index > 1 then
    local data = SB2_BAG_SETUP.CustomSections[index]
    table.remove(SB2_BAG_SETUP.CustomSections, index)
    table.insert(SB2_BAG_SETUP.CustomSections, index - 1, data)
  end
end

function SB2.ShiftDownSection(name)
  local index = SB2.GetSectionIndex(name)
  if index < #SB2_BAG_SETUP.CustomSections then
    local data = SB2_BAG_SETUP.CustomSections[index]
    table.remove(SB2_BAG_SETUP.CustomSections, index)
    table.insert(SB2_BAG_SETUP.CustomSections, index + 1, data)
  end
end
