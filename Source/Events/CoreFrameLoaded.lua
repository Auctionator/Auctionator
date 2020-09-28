-- Know Events:
-- AUCTION_CANCELED: auctionID
-- AUCTION_HOUSE_BROWSE_RESULTS_ADDED: addedBrowseResults
-- AUCTION_HOUSE_BROWSE_RESULTS_UPDATED
-- AUCTION_HOUSE_CLOSED
-- AUCTION_HOUSE_DISABLED
-- AUCTION_HOUSE_FAVORITES_UPDATED
-- AUCTION_HOUSE_SCRIPT_DEPRECATED
-- AUCTION_HOUSE_SHOW
-- AUCTION_MULTISELL_FAILURE
-- AUCTION_MULTISELL_START: numRepetitions
-- AUCTION_MULTISELL_UPDATE: createdCount, totalToCreate
-- BID_ADDED: bidID
-- BIDS_UPDATED
-- COMMODITY_PRICE_UNAVAILABLE
-- COMMODITY_PRICE_UPDATED: updatedUnitPrice, updatedTotalPrice
-- COMMODITY_PURCHASE_FAILED
-- COMMODITY_PURCHASE_SUCCEEDED
-- COMMODITY_PURCHASED: itemID, quantity
-- COMMODITY_SEARCH_RESULTS_ADDED: itemID
-- COMMODITY_SEARCH_RESULTS_UPDATED: itemID
-- EXTRA_BROWSE_INFO_RECEIVED: itemID
-- ITEM_KEY_ITEM_INFO_RECEIVED: itemID
-- ITEM_PURCHASED: itemID
-- ITEM_SEARCH_RESULTS_ADDED: itemKey
-- ITEM_SEARCH_RESULTS_UPDATED: itemKey, newAuctionID
-- OWNED_AUCTIONS_UPDATED
-- REPLICATE_ITEM_LIST_UPDATE

-- ORIGINAL EVENTS LISTENERS TODO
  -- -- self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
  -- -- self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
  -- -- self:RegisterEvent("NEW_AUCTION_UPDATE");


local AUCTIONATOR_EVENTS = {
  -- Addon Initialization Events
  "VARIABLES_LOADED",
  -- AH Window Initialization Events
  "AUCTION_HOUSE_SHOW",
  -- Trade Window Initialization Events
  "TRADE_SKILL_SHOW",
  -- Import list events
  -- "CHAT_MSG_ADDON"
}

-- Called from AuctionatorCore frame's OnLoad (defined in Auctionator.xml)
-- coreFrame: AuctionatorCore Frame (see Auctionator.xml)
function Auctionator.Events.CoreFrameLoaded(coreFrame)
  Auctionator.Debug.Message("Auctionator.Events.CoreFrameLoaded")
  C_ChatInfo.RegisterAddonMessagePrefix("Auctionator")

  for _, eventName in ipairs(AUCTIONATOR_EVENTS) do
    coreFrame:RegisterEvent(eventName)
  end
end
