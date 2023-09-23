SB2 = {}

SB2.Constants = {
  IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
  IsEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
}

SB2.Constants.Events = {
  "TriggerBagRefresh",
  "BagCacheUpdated",
  "BagRefresh",
  "BagItemClicked",
  "BagViewSectionToggled",
  "BagCacheOff",
  "BagCacheOn",

  "BagCustomise.NewSection",
  "BagCustomise.FocusSection",
  "BagCustomise.DeleteSection",
  "BagCustomise.RenameSection",
  "BagCustomise.HideSection",
  "BagCustomise.ShiftUpSection",
  "BagCustomise.ShiftDownSection",

  "BagCustomise.EditMade",
}

SB2.Constants.DialogNames = {
  CreateSection = "SB2.CreateSectionDialog",
  ConfirmDelete = "SB2.ConfirmDelete",
  RenameSection = "SB2.RenameSection",
}

if not SB2.Constants.IsRetail then
  -- Note that -2 is the keyring bag, which only exists in classic
  SB2.Constants.BagIDs = {-2, 0, 1, 2, 3, 4}
elseif SB2.Constants.IsRetail then
  SB2.Constants.BagIDs = {0, 1, 2, 3, 4, 5}
end

if SB2.Constants.IsRetail then
  SB2.Constants.ValidItemClassIDs = {
    Enum.ItemClass.Weapon,
    Enum.ItemClass.Armor,
    Enum.ItemClass.Container,
    Enum.ItemClass.Gem,
    Enum.ItemClass.ItemEnhancement,
    Enum.ItemClass.Consumable,
    Enum.ItemClass.Glyph,
    Enum.ItemClass.Tradegoods,
    Enum.ItemClass.Recipe,
    Enum.ItemClass.Profession,
    Enum.ItemClass.Battlepet,
    Enum.ItemClass.Questitem,
    Enum.ItemClass.Miscellaneous,
  }
elseif SB2.Constants.IsWrath then
  SB2.Constants.ValidItemClassIDs = {
    Enum.ItemClass.Weapon,
    Enum.ItemClass.Armor,
    Enum.ItemClass.Container,
    Enum.ItemClass.Consumable,
    Enum.ItemClass.Glyph,
    Enum.ItemClass.Tradegoods,
    Enum.ItemClass.Projectile,
    Enum.ItemClass.Quiver,
    Enum.ItemClass.Recipe,
    Enum.ItemClass.Gem,
    Enum.ItemClass.Miscellaneous,
    Enum.ItemClass.Questitem,
    Enum.ItemClass.Key,
  }
elseif SB2.Constants.IsVanilla then
  SB2.Constants.ValidItemClassIDs = {
    Enum.ItemClass.Weapon,
    Enum.ItemClass.Armor,
    Enum.ItemClass.Container,
    Enum.ItemClass.Consumable,
    Enum.ItemClass.Tradegoods,
    Enum.ItemClass.Projectile,
    Enum.ItemClass.Quiver,
    Enum.ItemClass.Recipe,
    Enum.ItemClass.Reagent,
    Enum.ItemClass.Miscellaneous,
  }
end

SB2.Constants.SectionType = {
  List = 1,
  ClassID = 2,
}

SB2.Constants.DefaultSections = {
}

for _, classID in ipairs(SB2.Constants.ValidItemClassIDs) do
  table.insert(SB2.Constants.DefaultSections, {
    name = GetItemClassInfo(classID),
    type = SB2.Constants.SectionType.ClassID,
    classID = classID,
  })
end

SB2.Constants.ItemSize = 42
