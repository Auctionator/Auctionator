AuctionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:OnLoad")
  Auctionator.EventBus:RegisterSource(self, "AuctionatorFullScanFrameMixin")
  self.state = Auctionator.SavedState
end

function AuctionatorFullScanFrameMixin:ResetData()
  self.scanData = {}
  self.dbKeysMapping = {}
end

function AuctionatorFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
    Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanStart)

    self.state.TimeOfLastReplicateScan = time()

    self.inProgress = true

    self:RegisterForEvents()
    Auctionator.Utilities.Message(AUCTIONATOR_L_STARTING_FULL_SCAN_REPLICATE)
    C_AuctionHouse.ReplicateItems()
    -- 10% complete after making the replicate request
    Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanProgress, 0.1)
  else
    Auctionator.Utilities.Message(self:NextScanMessage())
  end
end

function AuctionatorFullScanFrameMixin:IsAutoscanReady()
  local timeSinceLastScan = time() - (self.state.TimeOfLastReplicateScan or 0)

  return timeSinceLastScan >= (Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN_INTERVAL) * 60) and self:CanInitiate()
end

function AuctionatorFullScanFrameMixin:CanInitiate()
  return
   ( self.state.TimeOfLastReplicateScan ~= nil and
     time() - self.state.TimeOfLastReplicateScan > 60 * 15 and
     not self.inProgress
   ) or self.state.TimeOfLastReplicateScan == nil
end

function AuctionatorFullScanFrameMixin:NextScanMessage()
  local timeSinceLastScan = time() - self.state.TimeOfLastReplicateScan
  local minutesUntilNextScan = 15 - math.ceil(timeSinceLastScan / 60)
  local secondsUntilNextScan = (15 * 60 - timeSinceLastScan) % 60

  return AUCTIONATOR_L_NEXT_SCAN_MESSAGE:format(minutesUntilNextScan, secondsUntilNextScan)
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
  -- 20% complete after server response
  Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanProgress, 0.2)

  self:ResetData()
  self.waitingForData = C_AuctionHouse.GetNumReplicateItems()

  self:ProcessBatch(
    0,
    250,
    self.waitingForData
  )
end

function AuctionatorFullScanFrameMixin:ProcessBatch(startIndex, stepSize, limit)
  if startIndex >= limit then
    C_Timer.After(2, function()
      if self.waitingForData > 0 then
        self.waitingForData = 0
        self:EndProcessing()
      end
    end)
    return
  end

  -- 20-100% complete when 0-100% through caching the scan
  Auctionator.EventBus:Fire(self,
    Auctionator.FullScan.Events.ScanProgress,
    0.2 + startIndex/limit*0.8
  )

  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:ProcessBatch (links)", startIndex, stepSize, limit)

  local i = startIndex
  while i < startIndex+stepSize and i < limit do
    local info = { C_AuctionHouse.GetReplicateItemInfo(i) }
    local link = C_AuctionHouse.GetReplicateItemLink(i)
    local timeLeft = C_AuctionHouse.GetReplicateItemTimeLeft(i)
    local index = i

    -- Glitch in Blizzard APIs sometimes items with no item data are returned
    -- Workaround is to ignore them and filter out the nils after the scan is
    -- finished.
    if not C_Item.DoesItemExistByID(info[17]) then
      self.waitingForData = self.waitingForData - 1
      if self.waitingForData == 0 then
        self:EndProcessing()
      end
    elseif not info[18] then
      ItemEventListener:AddCallback(info[17], function()
        local link = C_AuctionHouse.GetReplicateItemLink(index)

        Auctionator.Utilities.DBKeyFromLink(link, function(dbKeys)
          self.waitingForData = self.waitingForData - 1

          self.scanData[index + 1] = {
            replicateInfo = { C_AuctionHouse.GetReplicateItemInfo(index) },
            itemLink      = link,
            timeLeft      = C_AuctionHouse.GetReplicateItemTimeLeft(index),
          }
          self.dbKeysMapping[index + 1] = dbKeys

          if self.waitingForData == 0 then
            self:EndProcessing()
          end
        end)
      end)
    else
      Auctionator.Utilities.DBKeyFromLink(link, function(dbKeys)
        self.waitingForData = self.waitingForData - 1
        self.scanData[index + 1] = {
          replicateInfo = info,
          itemLink      = link,
          timeLeft      = timeLeft,
        }
        self.dbKeysMapping[index + 1] = dbKeys

        if self.waitingForData == 0 then
          self:EndProcessing()
        end
      end)
    end

    i = i + 1
  end

  C_Timer.After(0.01, function()
    self:ProcessBatch(startIndex + stepSize, stepSize, limit)
  end)
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
        AUCTIONATOR_L_FULL_SCAN_FAILED_REPLICATE .. " " .. self:NextScanMessage()
      )
      Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanFailed)
    end
  end
end

local function GetInfo(replicateInfo, itemLink)
  local count = replicateInfo[3]
  local buyoutPrice = replicateInfo[10]
  local effectivePrice = buyoutPrice / count
  local available = replicateInfo[3]
    
  return effectivePrice, available
end


local function MergeInfo(scanData, dbKeysMapping)
  local allInfo = {}
  local index = 0

  for index = 1, #scanData do
    local effectivePrice, available = GetInfo(scanData[index].replicateInfo)

    -- Checks as apparently it returns 0 available in some cases
    if available > 0 and effectivePrice ~= 0 then
      for _, dbKey in ipairs(dbKeysMapping[index]) do
        if allInfo[dbKey] == nil then
          allInfo[dbKey] = {}
        end

        table.insert(allInfo[dbKey],
          { price = effectivePrice, available = available }
        )
      end
    end
  end

  return allInfo
end

function AuctionatorFullScanFrameMixin:EndProcessing()
  local fixedScanData = {}
  local fixedDbKeysMapping = {}

  -- Removes the nil holes for items that have item data missing
  for i = 1, #self.scanData do
    if self.scanData[i] ~= nil then
      table.insert(fixedScanData, self.scanData[i])
      table.insert(fixedDbKeysMapping, self.dbKeysMapping[i])
    end
  end

  local count = Auctionator.Database:ProcessScan(MergeInfo(fixedScanData, fixedDbKeysMapping))
  Auctionator.Utilities.Message(AUCTIONATOR_L_FINISHED_PROCESSING:format(count))

  self.inProgress = false
  self:ResetData()

  self:UnregisterForEvents()

  Auctionator.EventBus:Fire(self, Auctionator.FullScan.Events.ScanComplete, fixedScanData)
end
