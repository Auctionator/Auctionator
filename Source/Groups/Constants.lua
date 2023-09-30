Auctionator.BagGroups.Constants = {
  IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
  IsVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
}

Auctionator.BagGroups.Constants.Events = {
  "BagCacheUpdated",
  "GroupsViewGroupToggled",
  "GroupsViewComplete",

  "BagCacheOff",
  "BagCacheOn",

  "BagUse.BagItemClicked",
  "BagUse.AddToDefaultGroup",

  "GroupsCustomise.BagItemClicked",
  "GroupsCustomise.NewGroup",
  "GroupsCustomise.FocusGroup",
  "GroupsCustomise.DeleteGroup",
  "GroupsCustomise.RenameGroup",
  "GroupsCustomise.HideGroup",
  "GroupsCustomise.ShiftUpGroup",
  "GroupsCustomise.ShiftDownGroup",

  "GroupsCustomise.EditMade",
  "GroupsCustomise.PostingSettingChanged",
}

Auctionator.BagGroups.Constants.DialogNames = {
  CreateGroup = "Auctionator.BagGroups.CreateGroupDialog",
  ConfirmDelete = "Auctionator.BagGroups.ConfirmDelete",
  RenameGroup = "Auctionator.BagGroups.RenameGroup",
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

Auctionator.BagGroups.Constants.GroupType = {
  List = 1,
  ClassID = 2,
}

Auctionator.BagGroups.Constants.DefaultGroups = {
}

for _, classID in ipairs(Auctionator.BagGroups.Constants.ValidItemClassIDs) do
  table.insert(Auctionator.BagGroups.Constants.DefaultGroups, {
    name = GetItemClassInfo(classID),
    type = Auctionator.BagGroups.Constants.GroupType.ClassID,
    classID = classID,
  })
end
