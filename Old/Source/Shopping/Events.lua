Auctionator.Shopping.Events = {
  -- Changes to list meta data (including renames, deletes and pruning)
  ListMetaChange = "shopping list meta change",
  -- Changes to individual items in a list (edit, delete, add, etc.)
  ListItemChange = "shopping list item change",
  -- The list import code finished importing whatever data was supplied
  ListImportFinished = "shopping list import finished",

  RecentSearchesUpdate = "shopping tab recent searches update",
}

Auctionator.Shopping.Tab.Events = {
  SearchStart = "shopping tab search start",
  SearchEnd = "shopping tab search end",
  SearchIncrementalUpdate = "shopping tab search incremental update",

  DragItemStart = "shopping tab list drag item start",
  DragItemEnter = "shopping tab list drag item enter",
  DragItemStop = "shopping tab list drag item stop",

  ShowHistoricalPrices = "shopping show historical prices",
  UpdateSearchTerm = "shopping update search term",
  ListSearchRequested = "shopping list search requested",
  BuyScreenShown = "shopping list buy screen shown",
}
