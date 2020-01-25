function Auctionator.Events.OnAuctionHouseClosed()
  -- Atr_OnAuctionHouseClosed();
  if Auctionator.Scans.InitialScanStarted and (not Auctionator.Scans.FinishedReplication) then
      Auctionator.Scans.InitialScanStarted = false;
      print("Full Scan failed. Log out and back into WoW to try again.");
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
