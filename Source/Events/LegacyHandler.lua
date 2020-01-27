-- Called from AuctionatorCore frame's OnEvent (defined in Auctionator.xml)
-- self: AuctionatorCore Frame (see Auctionator.xml)
-- event: Event name string
function Auctionator.Events.LegacyHandler(self, event, ...)
  -- Auctionator.Debug.Message("Auctionator.Events.Handler", event)

  if event == "VARIABLES_LOADED" then
    Auctionator.Events.VariablesLoaded()
  elseif event == "ADDON_LOADED" then
    Auctionator.Events.AddonLoaded(...)
  elseif event == "PLAYER_ENTERING_WORLD" then
    Auctionator.Events.PlayerEnteringWorld()
  elseif event == "AUCTION_HOUSE_SHOW" then
    Auctionator.Events.OnAuctionHouseShow()
  elseif event == "AUCTION_HOUSE_CLOSED" then
    Auctionator.Events.OnAuctionHouseClosed()
  elseif event == "REPLICATE_ITEM_LIST_UPDATE" then
    Auctionator.Events.ReplicateItemListUpdate(...)
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    Auctionator.Events.BrowseResultsAdded(...)
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    Auctionator.Events.BrowseResultsUpdated(...)
  elseif event == "ITEM_SEARCH_RESULTS_ADDED" then
    Auctionator.Events.ItemSearchResultsAdded(...)
  elseif event == "ITEM_SEARCH_RESULTS_UPDATED" then
    Auctionator.Events.ItemSearchResultsUpdated(...)
  elseif event == "AUCTION_MULTISELL_START" then
    Auctionator.Events.AuctionMultisellStart(...)
  elseif event == "AUCTION_MULTISELL_UPDATE" then
    Auctionator.Events.AuctionMultisellUpdate(...)
  elseif event == "AUCTION_MULTISELL_FAILURE" then
    Auctionator.Events.AuctionMultisellFailure(...)
  elseif event == "CHAT_MSG_ADDON" then
    Auctionator.Events.ChatMessageAddon(...)
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
