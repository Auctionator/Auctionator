Auctionator.ItemLink = {
  item_link = '',
  item_string = nil,
  parsed_item_link = nil,
  item_id_string = nil,
  pet_id_string = nil,
  bonus_ids = nil,
  stage = nil,
  tier = nil
}

ITEM_ID_VERSION = "3.2.6"

function Auctionator.ItemLink:new( options )
  -- Auctionator.Debug.Message( 'ItemLink:new', options.item_link )

  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

function Auctionator.ItemLink:ItemString()
  if not self.item_string then
    _, _, self.item_string = self.item_link:find( '^|c%x+|H(.+)|h%[.*%]' )
  end

  return self.item_string
end

function Auctionator.ItemLink:ParsedItemLink()
  if not self.parsed_item_link and self:ItemString() then
    self.parsed_item_link = { strsplit( ':', self:ItemString() ) }
  end

  return self.parsed_item_link
end

function Auctionator.ItemLink:GetField( field_id )
  local field_value = (self:ParsedItemLink() or {})[ field_id ]

  if field_value == nil or field_value == '' then
    return 0
  else
    return field_value
  end
end

function Auctionator.ItemLink:IdString()
  local item_type = self:GetField( Auctionator.Constants.ItemLink.TYPE )

  if item_type == 'item' then
    return self:ItemIdString()
  elseif item_type == 'battlepet' then
    return self:BattlePetIdString()
  end
end

function Auctionator.ItemLink:ItemIdString()
  if not self.item_id_string then
    self.item_id_string = self:GetField( Auctionator.Constants.ItemLink.ID ) .. ':' ..
      self:Tier() .. ':' .. self:Stage() .. ':' .. self:Suffix()
  end

  return self.item_id_string
end

function Auctionator.ItemLink:Bonuses()
  if not self.bonus_ids then
    self.bonus_ids = {}

    for bonus_id = 1, self:BonusIdCount() do
      local bonus_value = tonumber(
        self:GetField( bonus_id + Auctionator.Constants.ItemLink.BONUS_ID_1 - 1  )
      )

      self.bonus_ids[ bonus_value ] = true
    end
  end

  return self.bonus_ids
end

function Auctionator.ItemLink:Tier()
  if not self.tier then
    self.tier = 0

    for tier_id, description in pairs( Auctionator.Constants.ItemLink.Tiers ) do
      if self:Bonuses()[ tier_id ] then
        self.tier = tier_id
      end
    end
  end

  return self.tier
end

function Auctionator.ItemLink:Stage()
  if not self.stage then
    self.stage = 0

    for stage_id, stage in pairs( Auctionator.Constants.ItemLink.Stages ) do
      if self:Bonuses()[ stage_id ] then
        self.stage = stage
      end
    end

  end

  return self.stage
end

function Auctionator.ItemLink:Suffix()
  return self:GetField( Auctionator.Constants.ItemLink.SUFFIX_ID )
end

function Auctionator.ItemLink:BattlePetIdString()
  if not self.pet_id_string then
    self.pet_id_string = self:GetField( Auctionator.Constants.ItemLink.ID ) ..
      ':' .. self:GetField( Auctionator.Constants.ItemLink.PET_LEVEL )
    Auctionator.Util.Print( self.parsed_item_link, self.pet_id_string )
  end

  return self.pet_id_string
end

function Auctionator.ItemLink:BonusIdCount()
  return tonumber( self:GetField( Auctionator.Constants.ItemLink.BONUS_ID_COUNT ) )
end

function Auctionator.ItemLink:IsBattlePet()
  local item_type = self:GetField( Auctionator.Constants.ItemLink.TYPE )

  return item_type == 'battlepet'
end