--
--  Auctionator.Filters is an empty table on load, need to populate
--  with the possible filters
--
--  Here's what one entry looks like:
--  {
--    classID    = integer (corresponding to ITEM_CLASS_IDS )
--    name       = string  (resolved by GetItemClassInfo( classID ))
--    filter     = table   (new QueryAuctionItems filterData format, { classID, subclassID (nil), inventoryType (nil) } )
--    subClasses = {
--      classID  = integer (subclassID)
--      name     = string  (resolved by GetItemSubClassInfo( subclassID ))
--      filter   = table   (new QueryAuctionItems filterData format, { classID, subclassID, inventoryType (nil) } )
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

Auctionator.QueryFilter = {
  classID = nil,
  subclassID = nil,
  inventoryType = nil
}

function Auctionator.QueryFilter:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

Auctionator.Filter = {
  classID = -1,
  name = nil,
  key = nil,
  filter = {},
  subClasses = {}
}

function Auctionator.Filter:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

local function GenerateSubClasses( classID, parentName )
  local subClassesTable = { GetAuctionItemSubClasses( classID ) }
  local subClasses = {}

  for i = 1, #subClassesTable do
    local subClassID = subClassesTable[ i ]
    local name = GetItemSubClassInfo( classID, subClassID )

    subClasses[ i ] = Auctionator.Filter:new({
      classID = subClassesID,
      name = name,
      key = parentName .. [[/]] .. name,
      filter = Auctionator.QueryFilter:new({ classID = classID, subclassID = subClassID })
    })
  end

  return subClasses
end

-- TODO: Will probably want to special case Armor for inventoryTypeFilters
for index, classID in ipairs( ITEM_CLASS_IDS ) do
  local name = GetItemClassInfo( classID )

  Auctionator.Filters[ classID ] = Auctionator.Filter:new({
    classID = classID,
    name = name,
    key = name,
    filter = Auctionator.QueryFilter:new({ classID = classID }),
    subClasses = GenerateSubClasses( classID, name )
  })
end

for index, filter in ipairs( Auctionator.Filters ) do
  local parent = filter

  Auctionator.FilterLookup[ parent.key ] = filter

  for i = 1, #filter.subClasses do
    local subFilter = filter.subClasses[ i ]

    Auctionator.FilterLookup[ subFilter.key ] = subFilter
  end
end