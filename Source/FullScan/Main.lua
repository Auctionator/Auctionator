  -- FullScan.State = {
  --   TimeOfLastScan = nil,
  --   Completed = false,
  --   InProgress = false
  -- },

function Auctionator.FullScan.CanInitiate()
  return
   ( Auctionator.FullScan.State.TimeOfLastScan ~= nil and
     time() - Auctionator.FullScan.State.TimeOfLastScan > 60 * 15 and
     not Auctionator.FullScan.State.InProgress
   ) or Auctionator.FullScan.State.TimeOfLastScan == nil
end

function Auctionator.FullScan.Initialize()
  if Auctionator.FullScan.CanInitiate() then

    Auctionator.FullScan.State.TimeOfLastScan = time()
    Auctionator.FullScan.State.Completed = false
    Auctionator.FullScan.State.InProgress = true
    Auctionator.FullScan.State.ReceivedInitialEvent = false
    -- Used to accept multiple replication events while waiting for object
    -- information
    Auctionator.FullScan.ReplicationState.ReplicationIndex = 0
    Auctionator.FullScan.ReplicationState.Prices = {}

    Auctionator.Utilities.Message("Starting a full scan.")
    C_AuctionHouse.ReplicateItems()
  else
    Auctionator.Utilities.Message(Auctionator.FullScan.NextScanMessage())
  end
end

function Auctionator.FullScan.NextScanMessage()
  local timeSinceLastScan = time() - Auctionator.FullScan.State.TimeOfLastScan
  local minutesUntilNextScan = 15 - math.floor(timeSinceLastScan / 60) - 1
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return
    "A full scan may be started in " ..
    minutesUntilNextScan ..
    " minutes and " ..
    secondsUntilNextScan ..
    " seconds."
end
