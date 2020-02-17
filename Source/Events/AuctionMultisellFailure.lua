function Auctionator.Events.AuctionMultisellFailure(...)
  Auctionator.Debug.Message("Auctionator.Events.AuctionMultisellFailure")

end


-----------------------------------------

function Atr_OnAuctionMultiSellFailure()
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellFailure' )

  if (not gAtr_SellTriggeredByAuctionator) then
    zc.md ("skipping.  gAtr_SellTriggeredByAuctionator is false");
    return;
  end

  -- add one more.  no good reason other than it just seems to work
  Atr_AddToScan (gJustPosted.ItemLink, gJustPosted.ItemName, gJustPosted.StackSize, gJustPosted.BuyoutPrice, 1);

  Atr_LogMsg (gJustPosted.ItemLink, gJustPosted.StackSize, gJustPosted.BuyoutPrice, gMS_stacksPrev + 1);
  Atr_AddHistoricalPrice (gJustPosted.ItemName, gJustPosted.BuyoutPrice / gJustPosted.StackSize, gJustPosted.StackSize, gJustPosted.ItemLink);

  gAtr_SellTriggeredByAuctionator = false;     -- reset

  if (Auctionator.State.CurrentPane.activeScan) then
    Auctionator.State.CurrentPane.activeScan.whenScanned = 0;
  end
end