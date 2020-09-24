AuctionatorFullScanFrameMixin = {}

local FULL_SCAN_EVENTS = {
  "REPLICATE_ITEM_LIST_UPDATE",
  "AUCTION_HOUSE_CLOSED"
}

function AuctionatorFullScanFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorFullScanFrameMixin:OnLoad")

  -- Updates to self.state should store in the SAVED_VARIABLE
  self.state = Auctionator.SavedState
end

function AuctionatorFullScanFrameMixin:ResetData()
  self.scanData = {}
end

function AuctionatorFullScanFrameMixin:InitiateScan()
  if self:CanInitiate() then
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

  local left = C_AuctionHouse.GetNumReplicateItems()

  for i = 0, C_AuctionHouse.GetNumReplicateItems() - 1 do
    local info = { C_AuctionHouse.GetReplicateItemInfo(i) }
    local link = C_AuctionHouse.GetReplicateItemLink(i)

    if not info[18] then
      local item = Item:CreateFromItemID(info[17])

      item:ContinueOnItemLoad(function()
        left = left - 1
        link = C_AuctionHouse.GetReplicateItemLink(i)

        table.insert(self.scanData, {
          auctionInfo = { C_AuctionHouse.GetReplicateItemInfo(i) },
          itemLink = link,
          key = Auctionator.Utilities.ItemKeyFromLink(link)
        })

        if left == 0 then
          self:EndProcessing()
        end
      end)
    else
      left = left - 1
      table.insert(self.scanData, {
        auctionInfo = info,
        itemLink = link,
        key = Auctionator.Utilities.ItemKeyFromLink(link)
      })
    end
  end

  if left == 0 then
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
    end
  end
end

local function GetInfo(auctionInfo, itemLink)
  local count = auctionInfo[3]
  local buyoutPrice = auctionInfo[10]
  local effectivePrice = buyoutPrice / count

  return effectivePrice
end

function AuctionatorFullScanFrameMixin:EndProcessing()
  local count = Auctionator.Database.ProcessScan(self:MergePrices())
  Auctionator.Utilities.Message(Auctionator.Locales.Apply("FINISHED_PROCESSING", count))

  self.inProgress = false
  self:ResetData()

  self:UnregisterForEvents()
end

function AuctionatorFullScanFrameMixin:MergePrices()
  local prices = {}
  local index = 0

  for index = 1, #self.scanData do
    local itemKey = self.scanData[index].key
    local effectivePrice = GetInfo(self.scanData[index].auctionInfo)

    if itemKey~=nil then
      if prices[itemKey] == nil then
        prices[itemKey] = { effectivePrice }
      else
        table.insert(prices[itemKey], effectivePrice)
      end
    end

    index = index + 1
  end

  return prices
end
