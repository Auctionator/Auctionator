AuctionatorUndercuttingFrameMixin = {}

function AuctionatorUndercuttingFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorUndercuttingFrameMixin:OnLoad()")

  self.ResultsListing:Init(self.DataProvider)
end
