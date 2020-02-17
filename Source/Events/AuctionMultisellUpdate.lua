-- AUCTION_MULTISELL_UPDATE: createdCount, totalToCreate
function Auctionator.Events.AuctionMultisellUpdate(createdCount, totalToCreate)
  Auctionator.Debug.Message("Auctionator.Events.AuctionMultisellUpdate", createdCount, totalToCreate)

end


-----------------------------------------

function Atr_OnAuctionMultiSellUpdate(...)
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellUpdate', ... )

  if (not gAtr_SellTriggeredByAuctionator) then
    zc.md ("skipping.  gAtr_SellTriggeredByAuctionator is false");
    return;
  end

  local stacksSoFar, stacksTotal = ...;

  --zc.md ("stacksSoFar: ", stacksSoFar, "stacksTotal: ", stacksTotal);

  local delta = stacksSoFar - gMS_stacksPrev;

  gMS_stacksPrev = stacksSoFar;

  Atr_AddToScan (gJustPosted.ItemLink, gJustPosted.ItemName, gJustPosted.StackSize, gJustPosted.BuyoutPrice, delta);

  if (stacksSoFar == stacksTotal) then
    Atr_LogMsg (gJustPosted.ItemLink, gJustPosted.StackSize, gJustPosted.BuyoutPrice, stacksTotal);
    Atr_AddHistoricalPrice (gJustPosted.ItemName, gJustPosted.BuyoutPrice / gJustPosted.StackSize, gJustPosted.StackSize, gJustPosted.ItemLink);
    gAtr_SellTriggeredByAuctionator = false;     -- reset
  end

end