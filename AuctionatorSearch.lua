Auctionator.Search = {
  text = nil,
  filter = nil,
  minLevel = nil,
  maxLevel = nil,
  parentKey = nil,
  subClassKey = nil,
  resolvedKey = nil,
  filterResolved = false,
  advanced = false
}

function Auctionator.Search:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

function Auctionator.Search:Start()

end

function Auctionator.Search:ToString()
  if self.advanced then
    return self.text .. [[ (Advanced)]]
  else
    return self.text
  end
end

function Auctionator.Search:Display()
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

  return table.concat( buffer, ' ' )
end


function Auctionator.Search:Filter()
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
