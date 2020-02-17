function Auctionator.Utilities.Search(queryString)
  local query = {}

  query.searchString = queryString
  query.minLevel = 0
  query.maxLevel = 1000
  query.filters = {}
  query.itemClassFilters = {}
  query.sorts = {}

  C_AuctionHouse.SendBrowseQuery(query)
end
