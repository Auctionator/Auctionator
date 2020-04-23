-- Called from AuctionatorCore frame's OnEvent (defined in Auctionator.xml)
-- self: AuctionatorCore Frame (see Auctionator.xml)
-- event: Event name string
function Auctionator.Events.Handler(self, event, ...)
  -- Auctionator.Debug.Message("Auctionator.Events.Handler", event, ...)

  if event == "VARIABLES_LOADED" then
    Auctionator.Events.VariablesLoaded()
  elseif event == "AUCTION_HOUSE_SHOW" then
    Auctionator.Events.OnAuctionHouseShow()
  end
end

-- TODO Where are these registered?
--   if (event == "UNIT_SPELLCAST_SENT")     then  Atr_OnSpellCastSent(...);     end;
--   if (event == "UNIT_SPELLCAST_SUCCEEDED")  then  Atr_OnSpellCastSucess(...);     end;
--   if (event == "BAG_UPDATE")          then  Atr_OnBagUpdate(...);     end;


-- TODO Delete; here for reference
-- TODO DEPRECATED (I think these are the browse results functions...)
--   -- if (event == "AUCTION_ITEM_LIST_UPDATE")  then  Atr_OnAuctionUpdate(...);       end;
--   -- if (event == "AUCTION_OWNED_LIST_UPDATE") then  Atr_OnAuctionOwnedUpdate();     end;
--   -- if (event == "NEW_AUCTION_UPDATE")      then  Atr_OnNewAuctionUpdate();       end;
