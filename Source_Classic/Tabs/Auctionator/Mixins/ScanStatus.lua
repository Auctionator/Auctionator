AuctionatorFullScanStatusMixin = {}

function AuctionatorFullScanStatusMixin:OnLoad()
  Auctionator.EventBus:Register(self, {
    Auctionator.FullScan.Events.ScanStart,
    Auctionator.FullScan.Events.ScanProgress,
    Auctionator.FullScan.Events.ScanComplete,
    Auctionator.FullScan.Events.ScanFailed,
  })
end

function AuctionatorFullScanStatusMixin:OnShow()
  self.Text:SetText("")
end

function AuctionatorFullScanStatusMixin:ReceiveEvent(event, eventData)
  if event == Auctionator.FullScan.Events.ScanStart then
    self.Text:SetText("0%")

  elseif event == Auctionator.FullScan.Events.ScanProgress then
    self.Text:SetText(tostring(math.floor(eventData*100)) .. "%")

  elseif event == Auctionator.FullScan.Events.ScanComplete then
    self.Text:SetText("100%")

  else
    self.Text:SetText("")
  end
end
