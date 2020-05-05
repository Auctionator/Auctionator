AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  if IsShiftKeyDown() then
    Auctionator.State.IncrementalScanFrameRef:ScanOnce()
  else
    Auctionator.State.FullScanFrameRef:InitiateScan()
  end
end
