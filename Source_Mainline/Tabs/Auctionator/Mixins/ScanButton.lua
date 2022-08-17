AuctionatorScanButtonMixin = {}

function AuctionatorScanButtonMixin:OnClick()
  if Auctionator.Config.Get(Auctionator.Config.Options.REPLICATE_SCAN) then
    if not IsControlKeyDown() then
      Auctionator.State.FullScanFrameRef:InitiateScan()
    else
      Auctionator.State.IncrementalScanFrameRef:InitiateScan()
    end
  else
    if not IsControlKeyDown() then
      Auctionator.State.IncrementalScanFrameRef:InitiateScan()
    else
      Auctionator.State.FullScanFrameRef:InitiateScan()
    end
  end
end
