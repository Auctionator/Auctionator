AuctionatorIncrementalScanFrameMixin = {}

local INCREMENTAL_SCAN_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorIncrementalScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:OnLoad")
  Auctionator.EventBus:RegisterSource(self, "AuctionatorIncrementalScanFrameMixin")

  self.doingFullScan = false
  self.state = Auctionator.SavedState

  self:RegisterForEvents()
end

function AuctionatorIncrementalScanFrameMixin:RegisterForEvents()
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:RegisterForEvents()")

  FrameUtil.RegisterFrameForEvents(self, INCREMENTAL_SCAN_EVENTS)
end

function AuctionatorIncrementalScanFrameMixin:UnregisterForEvents()
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:UnregisterForEvents()")

  FrameUtil.UnregisterFrameForEvents(self, INCREMENTAL_SCAN_EVENTS)
end

function AuctionatorIncrementalScanFrameMixin:OnEvent(event, ...)
  if event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then
    self.info = {} -- New search results so reset info
    self.rawScan = {}

    local browseResults = C_AuctionHouse.GetBrowseResults()
    -- Check this is probably the start of a new batch, as the UPDATED event
    -- will fire when doing other specific items searches (to update the price
    -- and quantity) on any size search results.
    if #browseResults <= Auctionator.Constants.SummaryBatchSize then
      self:AddPrices(browseResults)
      self:NextStep()
    end
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:AddPrices(...)
    self:NextStep()

  elseif event == "AUCTION_HOUSE_CLOSED" and self.doingFullScan then
    self.doingFullScan = false
    Auctionator.Utilities.Message(AUCTIONATOR_L_FULL_SCAN_FAILED_SUMMARY)
    Auctionator.EventBus:Fire(self, Auctionator.IncrementalScan.Events.ScanFailed)
  end
end

function AuctionatorIncrementalScanFrameMixin:IsAutoscanReady()
  local timeSinceLastScan = time() - (self.state.TimeOfLastBrowseScan or 0)

  return timeSinceLastScan >= (Auctionator.Config.Get(Auctionator.Config.Options.AUTOSCAN_INTERVAL) * 60)
end

function AuctionatorIncrementalScanFrameMixin:InitiateScan()
  if not self.doingFullScan then
    Auctionator.Utilities.Message(AUCTIONATOR_L_STARTING_FULL_SCAN_SUMMARY)
    self.state.TimeOfLastBrowseScan = time()
    Auctionator.AH.SendBrowseQuery({searchString = "", sorts = {}, filters = {}, itemClassFilters = {}})
    self.previousDatabaseCount = Auctionator.Database:GetItemCount()
    self.doingFullScan = true

    Auctionator.EventBus:Fire(self, Auctionator.IncrementalScan.Events.ScanStart)
    self:FireProgressEvent()
  else
    Auctionator.Utilities.Message(AUCTIONATOR_L_FULL_SCAN_IN_PROGRESS)
  end
end

function AuctionatorIncrementalScanFrameMixin:FireProgressEvent()
  local infoCount = 0

  if self.info ~= nil then
    for _, _  in pairs(self.info) do
      infoCount = infoCount + 1
    end
  end

  local dbCount = Auctionator.Database:GetItemCount()

  -- 10% complete after making the browse request
  local progress = 0.1

  if dbCount == 0 then
    -- 50% done if we don't have anything in the database
    progress = 0.5
  elseif dbCount > infoCount then
    -- 10%-90% complete when processing browse results
    progress = progress + 0.8 * infoCount / dbCount
  else
    -- 90% if got more browse results than prices already in the database
    progress = 0.9
  end

  Auctionator.EventBus:Fire(self, Auctionator.IncrementalScan.Events.ScanProgress, progress)
end

function AuctionatorIncrementalScanFrameMixin:AddPrices(results)
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:AddPrices()", results)

  for _, resultInfo in ipairs(results) do
    if resultInfo.totalQuantity ~= 0 then
      local allDBKeys = Auctionator.Utilities.DBKeyFromBrowseResult(resultInfo)

      for index, dbKey in ipairs(allDBKeys) do
        if self.info[dbKey] == nil then
          self.info[dbKey] = {}
        end

        table.insert(self.info[dbKey],
          { price = resultInfo.minPrice, available = resultInfo.totalQuantity }
        )
      end
      if self.doingFullScan then
        table.insert(self.rawScan, resultInfo)
      end
    end
  end

  if self.doingFullScan then
    self:FireProgressEvent()
  end
end

function AuctionatorIncrementalScanFrameMixin:NextStep()
  if self.doingFullScan and not Auctionator.AH.HasFullBrowseResults() then
    Auctionator.AH.RequestMoreBrowseResults()
  else
    local count = Auctionator.Database:ProcessScan(self.info)
    local rawScan = self.rawScan

    self.info = {} --Already processed, so clear
    self.rawScan = {}

    if self.doingFullScan then
      Auctionator.Utilities.Message(AUCTIONATOR_L_FINISHED_PROCESSING:format(count))
      self.doingFullScan = false

      Auctionator.EventBus:Fire(self, Auctionator.IncrementalScan.Events.ScanComplete, rawScan)
    end
    Auctionator.EventBus:Fire(self, Auctionator.IncrementalScan.Events.PricesProcessed)
  end
end
