Auctionator.Constants.ValidItemClassIDs = {
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

Auctionator.Constants.IsVanilla = true

local _, _, _, tocVersion = GetBuildInfo()
Auctionator.Constants.ElementInitializerCompatibility = tocVersion <= 11403

Auctionator.Constants.Durations = {
  Short = 2,
  Medium = 8,
  Long = 24,
}
