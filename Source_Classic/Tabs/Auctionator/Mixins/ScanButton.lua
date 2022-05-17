AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  Auctionator.State.FullScanFrameRef:InitiateScan()
end
