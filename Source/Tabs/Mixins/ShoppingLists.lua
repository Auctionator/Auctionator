AuctionatorShoppingListTabMixin = {}

function AuctionatorShoppingListTabMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListTabMixin:OnLoad()")

  self.ResultsListing:Init(self.DataProvider)
end