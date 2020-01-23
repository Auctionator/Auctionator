-- AUCTION_MULTISELL_START: numRepetitions
function Auctionator.Events.AuctionMultisellStart(numRepetitions)
  Auctionator.Debug.Message("Auctionator.Events.AuctionMultisellStart", numRepetitions)

end

-----------------------------------------

local gMS_stacksPrev;

-----------------------------------------

function Atr_OnAuctionMultiSellStart()
  Auctionator.Debug.Message( 'Atr_OnAuctionMultiSellStart' )

  gMS_stacksPrev = 0;
end