AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  if Auctionator.Config.Get(Auctionator.Config.Options.REPLICATE_SCAN) then
    Auctionator.State.FullScanFrameRef:InitiateScan()
  else
    Auctionator.State.IncrementalScanFrameRef:InitiateScan()
  end
end
