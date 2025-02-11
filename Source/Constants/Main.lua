Auctionator.Constants = {
  History = {
    NUMBER_OF_LINES = 20
  },
  RESULTS_DISPLAY_LIMIT = 100,

  AdvancedSearchDivider = ';',

  PET_CAGE_ID = 82800,
  WOW_TOKEN_ID = 122270,

  SCAN_DAY_0 = time({year=2020, month=1, day=1, hour=0}),

  SORT = {
    ASCENDING = 1,
    DESCENDING = 0
  },
  ITEM_TYPES = {
    ITEM = 1,
    COMMODITY = 2
  },
  INVENTORY_TYPE_IDS = {
    Enum.InventoryType.IndexHeadType,
    Enum.InventoryType.IndexShoulderType,
    Enum.InventoryType.IndexChestType,
    Enum.InventoryType.IndexWaistType,
    Enum.InventoryType.IndexLegsType,
    Enum.InventoryType.IndexFeetType,
    Enum.InventoryType.IndexWristType,
    Enum.InventoryType.IndexHandType,
  },
  EXPORT_TYPES = {
    STRING = 0,
    WHISPER = 1
  },
  NO_LIST = "",
  ITEM_LEVEL_THRESHOLD = 168,

  ShoppingListViews = {
    Lists = 1,
    Recents = 2,
  },

  RecentsListLimit = 30,

  Durations = {
    Short = 12,
    Medium = 24,
    Long = 48,
  },

  AfterAHCut = 0.95,
  IsClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,

  EnchantingVellumID = 38682,
}
