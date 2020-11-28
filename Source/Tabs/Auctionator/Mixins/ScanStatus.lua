AuctionatorFullScanStatusMixin = {}

function AuctionatorFullScanStatusMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.IncrementalScan.Events.ScanStart,
    Auctionator.IncrementalScan.Events.ScanProgress,
    Auctionator.IncrementalScan.Events.ScanComplete,
    Auctionator.IncrementalScan.Events.ScanFailed,
  })

  self.tick = false
end

function AuctionatorFullScanStatusMixin:OnShow()
  self.Text:SetText("")
end

function AuctionatorFullScanStatusMixin:ReceiveEvent(event, eventData)
  if event == Auctionator.IncrementalScan.Events.ScanStart then
    self.Text:SetText("0%")
  elseif event == Auctionator.IncrementalScan.Events.ScanProgress then
    if self.tick then
      self.Text:SetText("----")
    else
      self.Text:SetText("--")
    end
    self.tick = not self.tick
  elseif event == Auctionator.IncrementalScan.Events.ScanComplete then
    self.Text:SetText("100%")
  else
    self.Text:SetText("")
  end
end
