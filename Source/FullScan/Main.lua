  -- FullScanState = {
  --   TimeOfLastScan = nil,
  --   Completed = false,
  --   InProgress = false
  -- },

function Auctionator.FullScan.CanInitiate()
  return
   ( Auctionator.FullScanState.TimeOfLastScan ~= nil and
     time() - Auctionator.FullScanState.TimeOfLastScan > 60 * 15 and
     not Auctionator.FullScanState.InProgress
   ) or Auctionator.FullScanState.TimeOfLastScan == nil
end

function Auctionator.FullScan.Initialize()
  if Auctionator.FullScan.CanInitiate() then
    Auctionator.FullScanState = {
      TimeOfLastScan = time(),
      Completed = false,
      InProgress = true
    }

    Auctionator.Utilities.Message("Starting a full scan.")
    C_AuctionHouse.ReplicateItems()
  else


    Auctionator.Utilities.Message(Auctionator.FullScan.NextScanMessage())
  end
end

function Auctionator.FullScan.NextScanMessage()
  local timeUntilNextScan = time() - Auctionator.FullScanState.TimeOfLastScan

  return
    "A full scan may be started in " ..
    (timeUntilNextScan / 60) ..
    " minutes and " ..
    (timeUntilNextScan % 60) ..
    "seconds."
end