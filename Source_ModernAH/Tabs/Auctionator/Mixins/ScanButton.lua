AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  Auctionator.State.IncrementalScanFrameRef:InitiateScan()
end
