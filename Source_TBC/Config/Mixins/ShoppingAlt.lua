AuctionatorConfigShoppingAltFrameMixin = CreateFromMixins(AuctionatorConfigShoppingFrameMixin)

function AuctionatorConfigShoppingAltFrameMixin:OnShow()
  AuctionatorConfigShoppingFrameMixin.OnShow(self)

  self.FullRefresh:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOPPING_SHOW_ALL_RESULTS))
end

function AuctionatorConfigShoppingAltFrameMixin:Save()
  AuctionatorConfigShoppingFrameMixin.Save(self)

  Auctionator.Config.Set(Auctionator.Config.Options.SHOPPING_SHOW_ALL_RESULTS, self.FullRefresh:GetChecked())
end
