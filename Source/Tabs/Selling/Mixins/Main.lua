AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  -- self.BagResultsListing:Init(self.BagDataProvider)

  self.BagListing:Init(self.BagDataProvider)
end

function AuctionatorSellingTabMixin:OnShow()
end

function AuctionatorSellingTabMixin:OnEvent()
end
