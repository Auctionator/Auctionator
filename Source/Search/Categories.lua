--
--  Auctionator.Search.Categories is an empty table on load, need to populate
--  with the possible categories
--
--  Here's what one entry looks like:
--  {
--    classID    = integer (corresponding to ITEM_CLASS_IDS )
--    name       = string  (resolved by GetItemClassInfo( classID ))
--    category     = table   (new QueryAuctionItems categoryData format, { classID, subClassID (nil), inventoryType (nil) } )
--    subClasses = {
--      classID  = integer (subClassID)
--      name     = string  (resolved by GetItemSubClassInfo( subClassID ))
--      category   = table   (new QueryAuctionItems categoryData format, { classID, subClassID, inventoryType (nil) } )
--      TODO: Probably want to use the inventoryType to create Armor slot categories as well...
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

Auctionator.Search.Category = {
  classID = 0,
  name = Auctionator.Constants.CategoryDefault,
  key = 0,
  parentKey = nil,
  category = {},
  subClasses = {}
}

-- TODO: Ununsed in current code (was used in advanced search dialog)
function Auctionator.Search.Category.Find( key )
  local category = Auctionator.Search.CategoryLookup[ key ]

  if category == nil then
    return Auctionator.Search.Category:new(), Auctionator.Search.Category:new()
  elseif category.parentKey == nil then
    return category, Auctionator.Search.Category:new()
  else
    return Auctionator.Search.CategoryLookup[ category.parentKey ], category
  end
end

function Auctionator.Search.Category:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

--Given a key and category (classID and subClassID supplied, assumed to be for
--armor), creates a new category for each possible inventory slot.
--Returns array of new categories
local function GenerateArmorInventorySlots(parentKey, parentCategory)
  local inventorySlots = {}
  for index = 1, #INVENTORY_TYPE_IDS do
    local name = GetItemInventorySlotInfo(INVENTORY_TYPE_IDS[index])

    local category = {
      classID = parentCategory.classID,
      subClassID = parentCategory.subClassID,
      inventoryType = INVENTORY_TYPE_IDS[index],
    }
    local subSubClass = Auctionator.Search.Category:new({
      classID = subClassID,
      name = name,
      key = parentKey .. [[/]] .. name,
      parentKey = parentKey,
      category = { category }
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

    local category = { classID = classID, subClassID = subClassID }
    local subClass = Auctionator.Search.Category:new({
      classID = subClassID,
      name = name,
      key = parentKey .. [[/]] .. name,
      parentKey = parentKey,
      category = { category }
    })

    table.insert( subClasses, subClass )

    --Armor special case, adds inventory slot categories
    if classID == LE_ITEM_CLASS_ARMOR then
      local inventorySlots = GenerateArmorInventorySlots(subClass.key, category)
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
  local category = {classID = classID}

  local categoryCategory = Auctionator.Search.Category:new({
    classID = classID,
    name = name,
    key = key,
    category = {category},
    subClasses = subClasses
  })

  table.insert( Auctionator.Search.Categories, categoryCategory )
end

for index, category in ipairs( Auctionator.Search.Categories ) do
  Auctionator.Search.CategoryLookup[ category.key ] = category

  for i = 1, #category.subClasses do
    local subCategory = category.subClasses[ i ]

    Auctionator.Search.CategoryLookup[ subCategory.key ] = subCategory
  end
end
