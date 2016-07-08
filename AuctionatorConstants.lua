Auctionator.Constants = {
  SubClasses = {
    ITEM_CLASS_HERB = 9, -- Under LE_ITEM_CLASS_TRADEGOODS
    ITEM_CLASS_POTION = 1, -- Under LE_ITEM_CLASS_CONSUMABLE
    ITEM_CLASS_ELIXIR = 2, -- Under LE_ITEM_CLASS_CONSUMABLE
    ITEM_CLASS_FLASK = 3 -- Under LE_ITEM_CLASS_CONSUMABLE
  },

  SearchStates = {
    NULL = 0,
    PRE_QUERY = 1,
    IN_QUERY = 2, -- Replaced KM_INQUERY, not used?
    POST_QUERY = 3,
    ANALYZING = 4,
    SETTING_SORT = 5
  },

  Sort = {
    NAME_ASCENDING = 0,
    NAME_DESCENDING = 1, -- ATR_SORTBY_NAME_DES
    PRICE_ASCENDING = 2,
    PRICE_DESCENDING = 3 -- ATR_SORTBY_PRICE_DES
  },

  FilterDefault = '-------',

  ItemLink = {
    MAX = 27, -- Blarg, gimme length
    TYPE = 1,
    ID = 2,
    ENCHANT = 3,
    PET_LEVEL = 3,
    GEM_1 = 4,
    GEM_2 = 5,
    GEM_3 = 6,
    GEM_4 = 7,
    SUFFIX_ID = 8, -- Random enchant, old gear only (of the ...)
    UNIQUE_ID = 9, -- Used by server to calculate stats and store crafted by
    LEVEL = 10, -- level of the character that obtained the link
    UPGRADE_ID = 11,
    INSTANCE_DIFFICULTY_ID = 12,
    BONUS_IDS = 13, -- Not sure wtf this field is
    BONUS_ID_COUNT = 14, -- Adjust Item Level
    BONUS_ID_1 = 15, -- Modify Stats (of the ...)
    BONUS_ID_2 = 16, -- Change Item Quality
    BONUS_ID_3 = 17, -- Add Item Titles
    BONUS_ID_4 = 18, -- Append Words to Item Name
    BONUS_ID_5 = 19, -- Add Sockets
    BONUS_ID_6 = 20, -- Adjust Item Appearance ID
    BONUS_ID_7 = 21, -- Adjust Equip Level
    BONUS_ID_8 = 22, -- Unknown
    BONUS_ID_9 = 23, -- Unknown
    BONUS_ID_10 = 24, -- Unknown
    BONUS_ID_11 = 25, -- Unknown
    BONUS_ID_12 = 26, -- Unknown
    BONUS_ID_13 = 27, -- Unknown

    Tiers = { -- One possible use of Bonus ID
      [564] = 'Heroic', -- with prismatic gem slot
      [565] = 'Mythic', -- with prismatic gem slot
      [566] = 'Heroic',
      [567] = 'Mythic'
    },

    Stages = { -- One possible use of Bonus ID
      [525] = 1,
      [526] = 2,
      [558] = 2,
      [527] = 3,
      [559] = 3,
      [593] = 4,
      [594] = 4,
      [617] = 5,
      [619] = 5,
      [618] = 6,
      [620] = 6
    }
  }
}
