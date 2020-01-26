function Auctionator.Events.OnAuctionHouseClosed()
  -- Atr_OnAuctionHouseClosed();
  if (not Auctionator.Scans.FailureShown) and
      Auctionator.Scans.ScanStarted and (not Auctionator.Scans.FinishedReplication) then
      print("Full scan failed. Wait 15 minutes to try again.");
      Auctionator.Scans.FailureShown = true;
  end
end




-----------------------------------------

function Atr_OnAuctionHouseClosed()
  Auctionator.Debug.Message( 'Atr_OnAuctionHouseClosed' )

  Atr_HideAllDialogs();

  Atr_CheckingActive_Finish ();

  Atr_ClearScanCache();

  gSellPane:ClearSearch();
  gShopPane:ClearSearch();
  gMorePane:ClearSearch();

end
