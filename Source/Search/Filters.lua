--
--  Auctionator.Search.Filters is an empty table on load, need to populate
--  with the possible filters
--
--  Here's what one entry looks like:
--  {
--    classID    = integer (corresponding to ITEM_CLASS_IDS )
--    name       = string  (resolved by GetItemClassInfo( classID ))
--    filter     = table   (new QueryAuctionItems filterData format, { classID, subClassID (nil), inventoryType (nil) } )
--    subClasses = {
--      classID  = integer (subClassID)
--      name     = string  (resolved by GetItemSubClassInfo( subClassID ))
--      filter   = table   (new QueryAuctionItems filterData format, { classID, subClassID, inventoryType (nil) } )
--      TODO: Probably want to use the inventoryType to create Armor slot filters as well...
--    }
--  }

local ITEM_CLASS_IDS = {
  LE_ITEM_CLASS_WEAPON,
  LE_ITEM_CLASS_ARMOR,
  LE_ITEM_CLASS_CONTAINER,
  LE_ITEM_CLASS_GEM,
  LE_ITEM_CLASS_ITEM_ENHANCEMENT,
  LE_ITEM_CLASS_CONSUMABLE,
  LE_ITEM_CLASS_GLYPH,
  LE_ITEM_CLASS_TRADEGOODS,
  LE_ITEM_CLASS_RECIPE,
  LE_ITEM_CLASS_BATTLEPET,
  LE_ITEM_CLASS_QUESTITEM,
  LE_ITEM_CLASS_MISCELLANEOUS
}
local INVENTORY_TYPE_IDS = {
  LE_INVENTORY_TYPE_HEAD_TYPE,
  LE_INVENTORY_TYPE_SHOULDER_TYPE,
  LE_INVENTORY_TYPE_CHEST_TYPE,
  LE_INVENTORY_TYPE_WAIST_TYPE,
  LE_INVENTORY_TYPE_LEGS_TYPE,
  LE_INVENTORY_TYPE_FEET_TYPE,
  LE_INVENTORY_TYPE_WRIST_TYPE,
  LE_INVENTORY_TYPE_HAND_TYPE,
}

Auctionator.Search.Filter = {
  classID = 0,
  name = Auctionator.Constants.FilterDefault,
  key = 0,
  parentKey = nil,
  filter = {},
  subClasses = {}
}

-- XXX: Ununsed in current code (was used in advanced search dialog)
function Auctionator.Search.Filter.Find( key )
  local filter = Auctionator.Search.FilterLookup[ key ]

  if filter == nil then
    return Auctionator.Search.Filter:new(), Auctionator.Search.Filter:new()
  elseif filter.parentKey == nil then
    return filter, Auctionator.Search.Filter:new()
  else
    return Auctionator.Search.FilterLookup[ filter.parentKey ], filter
  end
end

function Auctionator.Search.Filter:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

local function GenerateArmorInventorySlots(parentKey, parentFilter)
  local inventorySlots = {}
  for index = 1, #INVENTORY_TYPE_IDS do
    local name = GetItemInventorySlotInfo(INVENTORY_TYPE_IDS[index])

    local filter = {
      classID = parentFilter.classID,
      subClassID = parentFilter.subClassID,
      inventoryType = INVENTORY_TYPE_IDS[index],
    }
    local subSubClass = Auctionator.Search.Filter:new({
      classID = subClassID,
      name = name,
      key = parentKey .. [[/]] .. name,
      parentKey = parentKey,
      filter = { filter }
    })

    table.insert( inventorySlots, subSubClass )
  end
  return inventorySlots
end

local function GenerateSubClasses( classID, parentKey )
  local subClassesTable = C_AuctionHouse.GetAuctionItemSubClasses( classID )
  local subClasses = {}

  for index = 1, #subClassesTable do
    local subClassID = subClassesTable[ index ]
    local name = GetItemSubClassInfo( classID, subClassID )

    local filter = { classID = classID, subClassID = subClassID }
    local subClass = Auctionator.Search.Filter:new({
      classID = subClassID,
      name = name,
      key = parentKey .. [[/]] .. name,
      parentKey = parentKey,
      filter = { filter }
    })

    table.insert( subClasses, subClass )
    if classID == LE_ITEM_CLASS_ARMOR then
      local inventorySlots = GenerateArmorInventorySlots(subClass.key, filter)
      for _, slot in ipairs(inventorySlots) do
        table.insert(subClasses, slot)
      end
    end
  end

  return subClasses
end

for index, classID in ipairs( ITEM_CLASS_IDS ) do
  local key = GetItemClassInfo( classID )
  local subClasses = GenerateSubClasses( classID, key )
  local filter = {classID = classID}

  local categoryFilter = Auctionator.Search.Filter:new({
    classID = classID,
    name = name,
    key = key,
    filter = {filter},
    subClasses = subClasses
  })

  table.insert( Auctionator.Search.Filters, categoryFilter )
end

for index, filter in ipairs( Auctionator.Search.Filters ) do
  Auctionator.Search.FilterLookup[ filter.key ] = filter

  for i = 1, #filter.subClasses do
    local subFilter = filter.subClasses[ i ]

    Auctionator.Search.FilterLookup[ subFilter.key ] = subFilter
  end
end
