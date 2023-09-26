Auctionator.BagGroups.Constants = {
  IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
  IsEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
}

Auctionator.BagGroups.Constants.Events = {
  "TriggerBagRefresh",
  "BagCacheUpdated",
  "BagRefresh",
  "BagItemClicked",
  "BagViewSectionToggled",
  "BagCacheOff",
  "BagCacheOn",

  "BagCustomise.BagItemClicked",
  "BagCustomise.NewSection",
  "BagCustomise.FocusSection",
  "BagCustomise.DeleteSection",
  "BagCustomise.RenameSection",
  "BagCustomise.HideSection",
  "BagCustomise.ShiftUpSection",
  "BagCustomise.ShiftDownSection",

  "BagCustomise.EditMade",
}

Auctionator.BagGroups.Constants.DialogNames = {
  CreateSection = "Auctionator.BagGroups.CreateSectionDialog",
  ConfirmDelete = "Auctionator.BagGroups.ConfirmDelete",
  RenameSection = "Auctionator.BagGroups.RenameSection",
}

if not Auctionator.BagGroups.Constants.IsRetail then
  -- Note that -2 is the keyring bag, which only exists in classic
  Auctionator.BagGroups.Constants.BagIDs = {-2, 0, 1, 2, 3, 4}
elseif Auctionator.BagGroups.Constants.IsRetail then
  Auctionator.BagGroups.Constants.BagIDs = {0, 1, 2, 3, 4, 5}
end

if Auctionator.BagGroups.Constants.IsRetail then
  Auctionator.BagGroups.Constants.ValidItemClassIDs = {
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
elseif Auctionator.BagGroups.Constants.IsWrath then
  Auctionator.BagGroups.Constants.ValidItemClassIDs = {
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
elseif Auctionator.BagGroups.Constants.IsVanilla then
  Auctionator.BagGroups.Constants.ValidItemClassIDs = {
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

Auctionator.BagGroups.Constants.SectionType = {
  List = 1,
  ClassID = 2,
}

Auctionator.BagGroups.Constants.DefaultSections = {
}

for _, classID in ipairs(Auctionator.BagGroups.Constants.ValidItemClassIDs) do
  table.insert(Auctionator.BagGroups.Constants.DefaultSections, {
    name = GetItemClassInfo(classID),
    type = Auctionator.BagGroups.Constants.SectionType.ClassID,
    classID = classID,
  })
end

Auctionator.BagGroups.Constants.ItemSize = 42
