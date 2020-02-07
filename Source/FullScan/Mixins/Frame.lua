AuctionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:OnLoad")

  -- Updates to self.state should store in the SAVED_VARIABLE
  self.state = Auctionator.FullScan.State
  self.processingComplete = false

  if self:CanInitiate() then
    self.state.TimeOfLastScan = time()
    self.state.InProgress = true

    Auctionator.Utilities.Message("Starting a full scan.")
    C_AuctionHouse.ReplicateItems()
  else
    Auctionator.Utilities.Message(self:NextScanMessage())
  end
end

function AuctionatorFullScanFrameMixin:CanInitiate()
  return
   ( self.state.TimeOfLastScan ~= nil and
     time() - self.state.TimeOfLastScan > 60 * 15 and
     not self.state.InProgress
   ) or self.state.TimeOfLastScan == nil
end

function AuctionatorFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - self.state.TimeOfLastScan
  local minutesUntilNextScan = 15 - math.floor(timeSinceLastScan / 60) - 1
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return
    "A full scan may be started in " ..
    minutesUntilNextScan ..
    " minutes and " ..
    secondsUntilNextScan ..
    " seconds."
end

function AuctionatorFullScanFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:OnEvent(event, ...)
  if event == "REPLICATE_ITEM_LIST_UPDATE" and not self.processingComplete then
    self:BeginProcessing()
  elseif event =="AUCTION_HOUSE_CLOSED" then
    -- Not sure if we need this anymore to stop processing?
  end
end

local function GetReplicateInfo(index)
  local replicateItemInfo = { C_AuctionHouse.GetReplicateItemInfo(index) }

  local count = replicateItemInfo[3]
  local buyoutPrice = replicateItemInfo[10]
  local effectivePrice = buyoutPrice / count

  local itemKey = Auctionator.Utilities.ItemKeyFromReplicateResult(replicateItemInfo)

  return itemKey, effectivePrice
end

function AuctionatorFullScanFrameMixin:BeginProcessing()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:BeginProcessing")

  local prices = {}
  local itemKey, effectivePrice

  for index = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    itemKey, effectivePrice = GetReplicateInfo(index)

    if itemKey~=nil then
      if prices[itemKey] == nil then
        prices[itemKey] = { effectivePrice }
      else
        table.insert(prices[itemKey], effectivePrice)
      end
    end
  end

  Auctionator.Database.ProcessFullScan(prices)

  self.processingComplete = true
end
