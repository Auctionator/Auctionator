Auctionator.Search = {
  text = nil,
  filter = nil,
  minLevel = nil,
  maxLevel = nil,
  parentKey = nil,
  subClassKey = nil,
  resolvedKey = nil,
  filterResolved = false
}

function Auctionator.Search:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

function Auctionator.Search:Start()

end

function Auctionator.Search:Display()
  local buffer = { self.text }

  if not self.filterResolved then
    self:Filter()
  end

  if self.resolvedKey ~= nil then
    table.insert( buffer, [[(]] .. self.resolvedKey .. [[)]] )
  end

  if self.maxLevel or self.minLevel then
    table.insert( buffer, self.minLevel .. [[-]] .. self.maxLevel )
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
