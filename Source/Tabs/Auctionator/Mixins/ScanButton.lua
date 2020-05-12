AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  if IsShiftKeyDown() then
    Auctionator.State.IncrementalScanFrameRef:InitiateScan()
  else
    Auctionator.State.FullScanFrameRef:InitiateScan()
  end
end
