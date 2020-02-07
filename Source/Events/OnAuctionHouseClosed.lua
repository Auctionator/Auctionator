function Auctionator.Events.OnAuctionHouseClosed()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseClosed")

  AuctionatorAHFrame:Hide()

  if Auctionator.FullScan.State.InProgress and not Auctionator.FullScan.State.Completed then
    Auctionator.FullScan.State.InProgress = false

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
