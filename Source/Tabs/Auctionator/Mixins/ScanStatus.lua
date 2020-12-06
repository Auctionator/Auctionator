AuctionatorFullScanStatusMixin = {}

function AuctionatorFullScanStatusMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.IncrementalScan.Events.ScanStart,
    Auctionator.IncrementalScan.Events.ScanProgress,
    Auctionator.IncrementalScan.Events.ScanComplete,
    Auctionator.IncrementalScan.Events.ScanFailed,
  })
end

function AuctionatorFullScanStatusMixin:OnShow()
  self.Text:SetText("")
end

function AuctionatorFullScanStatusMixin:ReceiveEvent(event, eventData)
  if event == Auctionator.IncrementalScan.Events.ScanStart then
    self.Text:SetText("0%")

  elseif event == Auctionator.IncrementalScan.Events.ScanProgress then
    self.Text:SetText(tostring(math.floor(eventData*100)) .. "%")

  elseif event == Auctionator.IncrementalScan.Events.ScanComplete then
    self.Text:SetText("100%")

  else
    self.Text:SetText("")
  end
end
