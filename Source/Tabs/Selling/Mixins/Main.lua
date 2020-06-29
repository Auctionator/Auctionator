AuctionatorSellingTabMixin = {}

function AuctionatorSellingTabMixin:OnLoad()
  self:ApplyShowPriceHistorySetting()

  self.BagListing:Init(self.BagDataProvider)

  self.HistoricalPriceListing:Init(self.HistoricalPriceProvider)
  self.HistoricalPriceListing:SetWidth(200)

  self.CurrentItemListing:Init(self.CurrentItemProvider)
  self.CurrentItemListing:SetWidth(200)
end

function AuctionatorSellingTabMixin:ApplyShowPriceHistorySetting()
  if not Auctionator.Config.Get(Auctionator.Config.Options.SHOW_SELLING_PRICE_HISTORY) then
    self.HistoricalPriceProvider:Hide()
    self.HistoricalPriceListing:Hide()
    self.CurrentItemListing:SetPoint("BOTTOM", self, "BOTTOM")
  end
end

function AuctionatorSellingTabMixin:OnEvent()
end
