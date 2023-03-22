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
  ListSelected = "AUCTIONATOR_LIST_SELECTED",
  ListCreated = "AUCTIONATOR_LIST_CREATED",
  ListRenamed = "AUCTIONATOR_LIST_RENAMED",

  ListItemAdded = "AUCTIONATOR_LIST_ITEM_ADDED",
  ListItemSelected = "AUCTIONATOR_LIST_ITEM_SELECTED",
  DeleteFromList = "AUCTIONATOR_DELETE_FROM_CURRENT_LIST",
  EditListItem = "AUCTIONATOR_EDIT_LIST_ITEM",
  CopyIntoList = "AUCTIONATOR_COPY_INTO_LIST",

  DragItemStart = "shopping tab list drag item start",
  DragItemEnter = "shopping tab list drag item enter",
  DragItemStop = "shopping tab list drag item stop",

  OneItemSearch = "shopping tab one item search",
  RecentSearchesUpdate = "shopping tab recent searches update",

  SearchForTerms = "AUCTIONATOR_SEARCH_FOR_TERMS",
  CancelSearch = "AUCTIONATOR_CANCEL_SEARCH",

  ListSearchStarted = "AUCTIONATOR_LIST_SEARCH_STARTED",
  ListSearchIncrementalUpdate = "AUCTIONATOR_LIST_SEARCH_INCREMENTAL_UPDATE",
  ListSearchEnded = "AUCTIONATOR_LIST_SEARCH_ENDED",
  ListSearchRequested = "AUCTIONATOR_LIST_SEARCH_REQUESTED",
  ListAbortSearch = "AUCTIONATOR_LIST_ABORT_SEARCH",

  DialogOpened = "SHOPPING_DIALOG_OPENED",
  DialogClosed = "SHOPPING_DIALOG_CLOSED",

  ShowHistoricalPrices = "SHOPPING_SHOW_HISTORICAL_PRICES",
}
