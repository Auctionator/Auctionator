--
--  Auctionator.Filters is an empty table on load, need to populate
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

Auctionator.Filter = {
  classID = 0,
  name = Auctionator.Constants.FilterDefault,
  key = 0,
  parentKey = nil,
  filter = {},
  subClasses = {}
}

-- TODO: Make this work, then can remove check in Atr_ASDD_Subclass_Initialize
-- Provides a null object for invalid lookups; intended use is for
-- rendering subclasses in Advanced Search UI
-- Auctionator.FilterLookup.__index = function()
--   return Auctionator.Filter:new()
-- end

function Auctionator.Filter.Find( key )
  local filter = Auctionator.FilterLookup[ key ]

  if filter == nil then
    return Auctionator.Filter:new(), Auctionator.Filter:new()
  elseif filter.parentKey == nil then
    return filter, Auctionator.Filter:new()
  else
    return Auctionator.FilterLookup[ filter.parentKey ], filter
  end
end

function Auctionator.Filter:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

local function GenerateSubClasses( classID, parentName, parentKey )
  local subClassesTable = { GetAuctionItemSubClasses( classID ) }
  local subClasses = {}
  local subFilters = {}

  for index = 1, #subClassesTable do
    local subClassID = subClassesTable[ index ]
    local name = GetItemSubClassInfo( classID, subClassID )

    local filter = { classID = classID, subClassID = subClassID }
    local subClass = Auctionator.Filter:new({
      classID = subClassID,
      name = name,
      key = parentKey .. [[/]] .. name,
      parentKey = parentKey,
      filter = { filter }
    })

    table.insert( subFilters, filter )
    table.insert( subClasses, subClass )
  end

  return subClasses, subFilters
end

-- TODO: Will probably want to special case Armor for inventoryTypeFilters
for index, classID in ipairs( ITEM_CLASS_IDS ) do
  local name = GetItemClassInfo( classID )
  local key = name
  local subClasses, filter = GenerateSubClasses( classID, name, key )

  local categoryFilter = Auctionator.Filter:new({
    classID = classID,
    name = name,
    key = key,
    filter = filter,
    subClasses = subClasses
  })

  table.insert( Auctionator.Filters, categoryFilter )
end

for index, filter in ipairs( Auctionator.Filters ) do
  Auctionator.FilterLookup[ filter.key ] = filter

  for i = 1, #filter.subClasses do
    local subFilter = filter.subClasses[ i ]

    Auctionator.FilterLookup[ subFilter.key ] = subFilter
  end
end
