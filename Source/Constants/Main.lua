Auctionator.Constants = {
  AdvancedSearchDivider = ';',

  PetCageID = 82800,
  WoWTokenID = 122270,

  ScanDay0 = time({year=2020, month=1, day=1, hour=0}),

  Sort = {
    Ascending = 1,
    Descending = 0
  },
  ItemType = {
    Item = 1,
    Commodity = 2
  },
  OldSlotTypes = {
    Enum.InventoryType.IndexHeadType,
    Enum.InventoryType.IndexShoulderType,
    Enum.InventoryType.IndexChestType,
    Enum.InventoryType.IndexWaistType,
    Enum.InventoryType.IndexLegsType,
    Enum.InventoryType.IndexFeetType,
    Enum.InventoryType.IndexWristType,
    Enum.InventoryType.IndexHandType,
  },
  NoList = "",

  ShoppingListViews = {
    Lists = 1,
    Recents = 2,
  },

  RecentsListLimit = 30,

  Durations = {
    Short = 1,
    Medium = 2,
    Long = 3,
  },

  ItemMatching = {
    Full = "full",
    BaseOnly = "base",
  },

  UndercutType = {
    Percentage = "percentage",
    Static = "static"
  },

  Shortcuts = {
    LeftClick = "left click",
    RightClick = "right click",
    AltLeftClick = "alt left click",
    ShiftLeftClick = "shift left click",
    AltRightClick = "alt right click",
    ShiftRightClick = "shift right click",
    None = "none",
  },

  AfterAHCut = 0.95,
  IsLegacyAH = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or IsUsingLegacyAuctionClient ~= nil and IsUsingLegacyAuctionClient(),
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
  IsVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,


  EnchantingVellumID = 38682,

}

if Auctionator.Constants.IsRetail then
  Auctionator.Constants.SellingBagIconSize = 42
  Auctionator.Constants.ItemLevelThreshold = 168
  Auctionator.Constants.QualityIDs = {
    Enum.ItemQuality.Poor,
    Enum.ItemQuality.Common,
    Enum.ItemQuality.Uncommon,
    Enum.ItemQuality.Rare,
    Enum.ItemQuality.Epic,
    Enum.ItemQuality.Legendary,
    Enum.ItemQuality.Artifact,
  }
else
  Auctionator.Constants.SellingBagIconSize = 35
  Auctionator.Constants.ItemLevelThreshold = 0
  Auctionator.Constants.QualityIDs = {
    Enum.ItemQuality.Poor,
    Enum.ItemQuality.Standard,
    Enum.ItemQuality.Good,
    Enum.ItemQuality.Rare,
    Enum.ItemQuality.Epic,
  }
end
