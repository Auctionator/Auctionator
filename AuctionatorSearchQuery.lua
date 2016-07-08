Auctionator.SearchQuery = {
  text = '',
  filter = nil,
  minLevel = nil,
  maxLevel = nil,
  parentKey = nil,
  subClassKey = nil,
  resolvedKey = nil,
  filterResolved = false,
  exactMatch = false,
  advanced = false
}

function Auctionator.SearchQuery:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

function Auctionator.SearchQuery:Start()

end

function Auctionator.SearchQuery:ToString()
  if self.advanced then
    return self.text .. [[ (Advanced)]]
  else
    return self.text
  end
end

function Auctionator.SearchQuery:RecentToString()
  local buffer = { self.text }
  local levelBuffer = {}

  if not self.filterResolved then
    self:Filter()
  end

  if self.resolvedKey ~= nil then
    table.insert( buffer, [[(]] .. self.resolvedKey .. [[)]] )
  end

  if self.minLevel ~= nil then
    table.insert( levelBuffer, self.minLevel )
  end

  if self.minLevel ~= nil and self.maxLevel ~= nil then
    table.insert( levelBuffer, '-' )
  end

  if self.maxLevel ~= nil then
    table.insert( levelBuffer, self.maxLevel )
  end

  if self.minLevel ~= nil or self.maxLevel ~= nil then
    table.insert( buffer, table.concat( levelBuffer, '' ) )
  end

  if self.exactMatch then
    table.insert( buffer, '(exact)' )
  end

  return table.concat( buffer, ' ' )
end


function Auctionator.SearchQuery:Filter()
  -- TODO: This could be made easier by tracking state on dropdown click in AuctionatorShop
  if not self.filterResolved and self.filter == nil then

    if self.subClassKey and self.subClassKey ~= 0 then
      self.resolvedKey = self.subClassKey
      self.filter = Auctionator.FilterLookup[ self.subClassKey ].filter
    elseif self.parentKey and self.parentKey ~= 0 then
      self.resolvedKey = self.parentKey
      self.filter = Auctionator.FilterLookup[ self.parentKey ].filter
    end

    self.filterResolved = true
  end

  return self.filter
end

function Auctionator.SearchQuery:SearchText()
  return Auctionator.Util.UTF8_Truncate( self.text )
end

function Auctionator.SearchQuery:SearchMinLevel()
  if self.minLevel == 0 then
    return nil
  else
    return self.minLevel
  end
end

function Auctionator.SearchQuery:SearchMaxLevel()
  if self.maxLevel == 0 then
    return nil
  else
    return self.maxLevel
  end
end

function Auctionator.SearchQuery:ToParams( currentPage )
  return self:SearchText(), self:SearchMinLevel(), self:SearchMaxLevel(), currentPage, nil, nil, false, self.exactMatch, self.filter
end