AuctionatorIncrementalScanFrameMixin = {}

local INCREMENTAL_SCAN_EVENTS = {
  "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
  "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorIncrementalScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:OnLoad")

  self.doingFullScan = false

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
    self.prices = {} -- New search results so reset prices

    self:AddPrices(C_AuctionHouse.GetBrowseResults())
    self:NextStep()
  elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
    self:AddPrices(...)
    self:NextStep()

  elseif event == "AUCTION_HOUSE_CLOSED" and self.doingFullScan then
    self.doingFullScan = false
    Auctionator.Utilities.Message(AUCTIONATOR_L_FULL_SCAN_ALTERNATE_FAILED)
  end
end

function AuctionatorIncrementalScanFrameMixin:InitiateScan()
  Auctionator.Utilities.Message(AUCTIONATOR_L_STARTING_FULL_SCAN_ALTERNATE)
  Auctionator.AH.SendBrowseQuery({searchString = "", sorts = {}, filters = {}, itemClassFilters = {}})
  self.doingFullScan = true
end

function AuctionatorIncrementalScanFrameMixin:AddPrices(results)
  Auctionator.Debug.Message("AuctionatorIncrementalScanFrameMixin:AddPrices()", results)

  for _, resultInfo in ipairs(results) do
    local itemKey = Auctionator.Utilities.ItemKeyFromBrowseResult(resultInfo)
    if self.prices[itemKey] == nil then
      self.prices[itemKey] = { resultInfo.minPrice }
    else
      table.insert(self.prices[itemKey], resultInfo.minPrice)
    end
  end
end

function AuctionatorIncrementalScanFrameMixin:NextStep()
  if not Auctionator.AH.HasFullBrowseResults() then
    Auctionator.AH.RequestMoreBrowseResults()
  else
    local count = Auctionator.Database.ProcessScan(self.prices)

    if self.doingFullScan then
      Auctionator.Utilities.Message(AUCTIONATOR_L_FINISHED_PROCESSING:format(count))
      self.doingFullScan = false
    end

    self.prices = {} --Already processed, so clear
  end
end
