AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self.BagListing:Init(self.BagDataProvider)
end
