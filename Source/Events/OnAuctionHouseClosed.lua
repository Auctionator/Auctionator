function Auctionator.Events.OnAuctionHouseClosed()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseClosed")

  Auctionator.State.ShoppingListFrameRef:Hide()
  Auctionator.State.ScanFrameRef:UnregisterForEvents()

  if Auctionator.FullScan.State.InProgress then
    Auctionator.FullScan.State.InProgress = false
    if not Auctionator.FullScan.State.QuickCompleted then
      Auctionator.Utilities.Message(
        "Full scan failed to complete. " ..
        Auctionator.FullScan.NextScanMessage()
      )
    elseif not Auctionator.DetailedCompleted then
      Auctionator.Utilities.Message(
        "Detailed full scan failed to complete. Some gear or pet information may be inaccurate. " ..
        Auctionator.FullScan.NextScanMessage()
      )
    end
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
