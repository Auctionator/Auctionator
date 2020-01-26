  -- FullScan = {
  --   TimeOfLastScan = nil,
  --   Completed = false,
  --   InProgress = false
  -- },

function Auctionator.FullScan.CanInitiate()
  return
   ( Auctionator.FullScan.TimeOfLastScan ~= nil and
     time() - Auctionator.FullScan.TimeOfLastScan > 60 * 15 and
     not Auctionator.FullScan.InProgress
   ) or Auctionator.FullScan.TimeOfLastScan == nil
end

function Auctionator.FullScan.Initialize()
  if Auctionator.FullScan.CanInitiate() then
    Auctionator.FullScan = {
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
  local timeUntilNextScan = time() - Auctionator.FullScan.TimeOfLastScan

  return
    "A full scan may be started in " ..
    (timeUntilNextScan / 60) ..
    " minutes and " ..
    (timeUntilNextScan % 60) ..
    "seconds."
end