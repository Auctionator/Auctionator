function Auctionator.Events.OnAuctionHouseClosed()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseClosed")

  Auctionator.State.ShoppingListFrameRef:Hide()
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
