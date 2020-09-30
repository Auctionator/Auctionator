AuctionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:OnLoad")
  Auctionator.EventBus:RegisterSource(self, "AuctionatorFullScanFrameMixin")

  -- Updates to self.state should store in the SAVED_VARIABLE
  self.state = Auctionator.SavedState
end

function AuctionatorFullScanFrameMixin:ResetData()
  self.scanData = {}
end

function AuctionatorFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
    Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanStart)

    self.state.TimeOfLastScan = time()

    self.inProgress = true

    self:RegisterForEvents()
    Auctionator.Utilities.Message(Auctionator.Locales.Apply("STARTING_FULL_SCAN"))
    Auctionator.AH.ReplicateItems()
  else
    Auctionator.Utilities.Message(self:NextScanMessage())
  end
end

function AuctionatorFullScanFrameMixin:CanInitiate()
  return
   ( self.state.TimeOfLastScan ~= nil and
     time() - self.state.TimeOfLastScan > 60 * 15 and
     not self.inProgress
   ) or self.state.TimeOfLastScan == nil
end

function AuctionatorFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - self.state.TimeOfLastScan
  local minutesUntilNextScan = 15 - math.floor(timeSinceLastScan / 60) - 1
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return
    Auctionator.Locales.Apply(
      "NEXT_SCAN_MESSAGE",
      minutesUntilNextScan,
      secondsUntilNextScan
    )
end

function AuctionatorFullScanFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, FULL_SCAN_EVENTS)
end

function AuctionatorFullScanFrameMixin:CacheScanData()
  self:ResetData()
  self.waitingForData = C_AuctionHouse.GetNumReplicateItems()

  self:ProcessBatch(
    0,
    Auctionator.Config.Get(Auctionator.Config.Options.FULL_SCAN_STEP),
    self.waitingForData
  )
end

function AuctionatorFullScanFrameMixin:ProcessBatch(startIndex, stepSize, limit)
  if startIndex >= limit then
    return
  end

  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:ProcessBatch (links)", startIndex, stepSize, limit)

  local i = startIndex
  while i < startIndex+stepSize and i < limit do
    local info = { C_AuctionHouse.GetReplicateItemInfo(i) }
    local link = C_AuctionHouse.GetReplicateItemLink(i)
    local timeLeft = C_AuctionHouse.GetReplicateItemTimeLeft(i)

    if not info[18] then
      local item = Item:CreateFromItemID(info[17])

      item:ContinueOnItemLoad((function(index)
        return function()
          self.waitingForData = self.waitingForData - 1

          table.insert(self.scanData, {
            replicateInfo = { C_AuctionHouse.GetReplicateItemInfo(index) },
            itemLink      = C_AuctionHouse.GetReplicateItemLink(index),
            timeLeft      = C_AuctionHouse.GetReplicateItemTimeLeft(index)
          })

          if self.waitingForData == 0 then
            self:EndProcessing()
          end
        end
      end)(i))
    else
      self.waitingForData = self.waitingForData - 1
      table.insert(self.scanData, {
        replicateInfo = info,
        itemLink      = link,
        timeLeft      = timeLeft
      })
    end

    i = i + 1
  end

  C_Timer.After(0.01, function()
    self:ProcessBatch(startIndex + stepSize, stepSize, limit)
  end)

  if self.waitingForData == 0 then
    self:EndProcessing()
  end
end

function AuctionatorFullScanFrameMixin:OnEvent(event, ...)
  if event == "REPLICATE_ITEM_LIST_UPDATE" then
    Auctionator.Debug.Message("REPLICATE_ITEM_LIST_UPDATE")

    FrameUtil.UnregisterFrameForEvents(self, { "REPLICATE_ITEM_LIST_UPDATE" })
    self:CacheScanData()
  elseif event =="AUCTION_HOUSE_CLOSED" then
    self:UnregisterForEvents()

    if self.inProgress then
      self.inProgress = false
      self:ResetData()

      Auctionator.Utilities.Message(
        Auctionator.Locales.Apply("FULL_SCAN_FAILED") ..
        " " .. self:NextScanMessage()
      )
      Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanFailed)
    end
  end
end

local function GetInfo(replicateInfo, itemLink)
  local count = replicateInfo[3]
  local buyoutPrice = replicateInfo[10]
  local effectivePrice = buyoutPrice / count

  local itemKey = Auctionator.Utilities.ItemKeyFromLink(itemLink)

  return itemKey, effectivePrice
end

function AuctionatorFullScanFrameMixin:EndProcessing()
  if Auctionator.Config.Get(Auctionator.Config.Options.CACHE_FULL_SCAN) then
    AUCTIONATOR_RAW_FULL_SCAN[Auctionator.Variables.GetConnectedRealmRoot()] = self.scanData
  else
    --Remove cache to save storage space
    AUCTIONATOR_RAW_FULL_SCAN = {}
  end

  local count = Auctionator.Database.ProcessScan(self:MergePrices())
  Auctionator.Utilities.Message(Auctionator.Locales.Apply("FINISHED_PROCESSING", count))

  self.inProgress = false
  self:ResetData()

  self:UnregisterForEvents()

  Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanComplete)
end

function AuctionatorFullScanFrameMixin:MergePrices()
  local prices = {}
  local index = 0

  for index = 1, #self.scanData do
    local itemKey, effectivePrice = GetInfo(self.scanData[index].replicateInfo, self.scanData[index].itemLink)

    if prices[itemKey] == nil then
      prices[itemKey] = { effectivePrice }
    else
      table.insert(prices[itemKey], effectivePrice)
    end

    index = index + 1
  end

  return prices
end
