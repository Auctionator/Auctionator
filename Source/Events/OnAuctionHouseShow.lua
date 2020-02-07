function Auctionator.Events.OnAuctionHouseShow()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow")

  AuctionatorAHFrame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", -2, 0)
  AuctionatorAHFrame:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMRIGHT", -2, 0)

  AuctionatorAHFrame:Show()

  Auctionator.FullScan.Initialize()
  Auctionator.FullScan.State.Completed = false
end

function Atr_OnAuctionHouseShow()
  Auctionator.Debug.Message( 'Atr_OnAuctionHouseShow' );



  -- if (AUCTIONATOR_DEFTAB == 1) then
  --   Auctionator.Debug.Message('AUCTIONATOR_DEFTAB == 1');
  --   Atr_SelectPane (Auctionator.Constants.Tabs.SELL_TAB);
  -- end

  -- if (AUCTIONATOR_DEFTAB == 2) then
  --   Auctionator.Debug.Message('AUCTIONATOR_DEFTAB == 2');
  --   Atr_SelectPane (Auctionator.Constants.Tabs.BUY_TAB);
  -- end

  -- if (AUCTIONATOR_DEFTAB == 3) then
  --   Auctionator.Debug.Message('AUCTIONATOR_DEFTAB == 3');
  --   Atr_SelectPane (Auctionator.Constants.Tabs.MORE_TAB);
  -- end


  -- Atr_ResetDuration();

  -- -- TODO need to put this on the global object in state....
  -- -- gJustPosted.ItemName = nil;
  -- -- gSellPane:ClearSearch();

  -- if (Auctionator.State.CurrentPane) then
  --   Auctionator.State.CurrentPane.UINeedsUpdate = true;
  -- end
end
