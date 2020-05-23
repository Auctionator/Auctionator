AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self.BagListing:Init(self.BagDataProvider)
  self.HistoricalPriceListing:Init(self.HistoricalPriceProvider)
  self.HistoricalPriceListing:SetWidth(200)
end

function AuctionatorSellingTabMixin:OnShow()
end

function AuctionatorSellingTabMixin:OnEvent()
end
