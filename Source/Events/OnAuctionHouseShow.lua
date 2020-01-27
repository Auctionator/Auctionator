function Auctionator.Events.OnAuctionHouseShow()
  Auctionator.Debug.Message("Auctionator.Events.OnAuctionHouseShow")
end

-----------------------------------------

function Atr_OnAuctionHouseShow()
  Auctionator.Debug.Message( 'Atr_OnAuctionHouseShow' );
  -- local frame = CreateFrame("Frame", "AuctionatorMain", AuctionHouseFrame, "SimplePanelTemplate");
  -- frame:SetPoint("TOPLEFT", AuctionHouseFrame, "TOPRIGHT", -2, -20)
  -- frame:SetPoint("BOTTOMLEFT", AuctionHouseFrame, "BOTTOMRIGHT", -2, 5)
  -- frame:SetWidth(500)

  -- local inset = frame.Inset

  -- for k, v in pairs(frame) do
  --   print(k)
  -- end

  -- local title = frame:CreateFontString(nil, "OVERLAY")
  -- title:SetPoint("BOTTOM", inset, "TOP", 0, 3)
  -- title:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
  -- title:SetJustifyH("LEFT")
  -- title:SetTextColor(1, 0.8, 0)
  -- title:SetText("Auctionator")

  -- local button = CreateFrame("Button", "AuctionatorTempButton", frame, "UIPanelDynamicResizeButtonTemplate")
  -- button:SetPoint("BOTTOM", inset, "BOTTOM", 0, 3)
  -- button:SetText("Placeholder")

  -- local fullScanButton = CreateFrame("Button", "AuctionatorFullScanButton", frame, "UIPanelDynamicResizeButtonTemplate")

  -- fullScanButton:SetText("Full Scan")
  -- fullScanButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)


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
