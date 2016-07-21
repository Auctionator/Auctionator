Auctionator.Constants.SearchStates = {
  NULL = 0,
  PRE_QUERY = 1,
  IN_QUERY = 2, -- Replaced KM_INQUERY, not used?
  POST_QUERY = 3,
  ANALYZING = 4,
  SETTING_SORT = 5
}

Auctionator.Constants.Sort = {
  NAME_ASCENDING = 0,
  NAME_DESCENDING = 1, -- ATR_SORTBY_NAME_DES
  PRICE_ASCENDING = 2,
  PRICE_DESCENDING = 3 -- ATR_SORTBY_PRICE_DES
}

Auctionator.Constants.FilterDefault = '-------'
Auctionator.Constants.AdvancedSearchDivider = ';'