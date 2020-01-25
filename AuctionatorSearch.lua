Auctionator.OldSearch = {
  query = nil,
  timeFinished = nil,

  -- itemName = nil, NOW query.text
  -- IDString, These aren't yet used, need to find the DoOldSearch that passes these
  -- itemLink,
  -- rescanThreshold

  processingState = Auctionator.Constants.SearchStates.NULL,
  currentPage = 0,
  items = {},
  atr_query = {}, -- Atr_NewQuery() used to be query... I think this is a page of results?
  sortedScans = nil,
  sortOrder = Auctionator.Constants.Sort.PRICE_ASCENDING, -- Used to be sortHow
}

function Auctionator.OldSearch:new( options )
  options = options or {}
  setmetatable( options, self )
  self.__index = self

  return options
end

function Auctionator.OldSearch:Start()
  Auctionator.Debug.Message( 'Auctionator.OldSearch:Start' )

  if CanSendAuctionQuery() then
    QueryAuctionItems( self.query:ToParams( self.currentPage ) )
  else
    Auctionator.Debug.Message( 'CanSendAuctionQuery FALSE' )
  end
end

function Auctionator.OldSearch:Finish()
  self.timeFinished = time()
  -- TODO: Why is there just a FINISHED OldSearchState?
  self.processingState = Auctionator.Constants.SearchStates.NULL
  self.currentPage = -1
end
