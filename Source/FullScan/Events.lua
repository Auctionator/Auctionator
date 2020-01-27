Auctionator.Events.Register("AUCTION_HOUSE_SHOW", Auctionator.FullScan.Initialize);

Auctionator.Events.Register("AUCTION_HOUSE_CLOSED", Auctionator.FullScan.Abort);

Auctionator.Events.Register("REPLICATE_ITEM_LIST_UPDATE", Auctionator.FullScan.ProcessReplicateResults)
