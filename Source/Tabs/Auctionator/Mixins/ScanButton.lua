AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  if Auctionator.Config.Get(Auctionator.Config.Options.ALTERNATE_SCAN_MODE) then
    if IsShiftKeyDown() then
      Auctionator.State.FullScanFrameRef:InitiateScan()
    else
      Auctionator.State.IncrementalScanFrameRef:InitiateScan()
    end
  else
    if IsShiftKeyDown() then
      Auctionator.State.IncrementalScanFrameRef:InitiateScan()
    else
      Auctionator.State.FullScanFrameRef:InitiateScan()
    end
  end
end
