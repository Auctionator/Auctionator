function Auctionator.Events.OnAuctionHouseClosed()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseClosed")

  if Auctionator.FullScan.InProgress and not Auctionator.FullScan.Completed then
    Auctionator.FullScan.InProgress = false

    Auctionator.Utilities.Message(
      "Full scan failed to complete. " ..
      Auctionator.FullScan.NextScanMessage()
    )
  end
end


-- function Atr_OnAuctionHouseClosed()
--   Auctionator.Debug.Message( 'Atr_OnAuctionHouseClosed' )

--   Atr_HideAllDialogs();

--   Atr_CheckingActive_Finish ();

--   Atr_ClearScanCache();

--   gSellPane:ClearSearch();
--   gShopPane:ClearSearch();
--   gMorePane:ClearSearch();

-- end
