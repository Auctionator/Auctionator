--
--  Auctionator.Search.Categories is an empty table on load, need to populate
--  with the possible categories
--
--  Here's what one entry looks like:
--  {
--    classID    = integer (corresponding to Auctionator.Constants.ValidItemClassIDs )
--    name       = string  (resolved by GetItemClassInfo( classID ))
--    category     = table   (new QueryAuctionItems categoryData format, { classID, subClassID (nil), inventoryType (nil) } )
--    subClasses = {
--      classID  = integer (subClassID)
--      name     = string  (resolved by GetItemSubClassInfo( subClassID ))
--      category   = table   (new QueryAuctionItems categoryData format, { classID, subClassID, inventoryType? } )
--    }
--  }

local INVENTORY_TYPE_IDS = Auctionator.Constants.INVENTORY_TYPE_IDS

Auctionator.Search.Category = {
  classID = 0,
  name = Auctionator.Constants.CategoryDefault,
  key = 0,
  parentKey = nil,
  category = {},
  subClasses = {}
}

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
      classID = INVENTORY_TYPE_IDS[index],
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
  local subClassesTable = Auctionator.AH.GetAuctionItemSubClasses( classID )
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
    if classID == Enum.ItemClass.Armor then
      local inventorySlots = GenerateArmorInventorySlots(subClass.key, category)
      for _, slot in ipairs(inventorySlots) do
        table.insert(subClasses, slot)
      end
    end
  end

  return subClasses
end

function Auctionator.Search.Categories.Initialize()
  for _, classID in ipairs( Auctionator.Constants.ValidItemClassIDs ) do
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

  for _, category in ipairs( Auctionator.Search.Categories ) do
    Auctionator.Search.CategoryLookup[ category.key ] = category

    for i = 1, #category.subClasses do
      local subCategory = category.subClasses[ i ]

      Auctionator.Search.CategoryLookup[ subCategory.key ] = subCategory
    end
  end
end

function Auctionator.Search.GetItemClassCategories(categoryKey)
  local lookup = Auctionator.Search.CategoryLookup[categoryKey]
  if lookup ~= nil then
    return lookup.category
  else
    return {}
  end
end
