AuctionatorConfigShoppingAltFrameMixin = CreateFromMixins(AuctionatorConfigShoppingFrameMixin)

function AuctionatorConfigShoppingAltFrameMixin:ShowSettings()
  AuctionatorConfigShoppingFrameMixin.ShowSettings(self)

  self.AlwaysLoadMore:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOPPING_ALWAYS_LOAD_MORE))
  self.ComputeListTotal:SetChecked(Auctionator.Config.Get(Auctionator.Config.Options.SHOPPING_COMPUTE_LIST_TOTAL))
end

function AuctionatorConfigShoppingAltFrameMixin:Save()
  AuctionatorConfigShoppingFrameMixin.Save(self)

  Auctionator.Config.Set(Auctionator.Config.Options.SHOPPING_ALWAYS_LOAD_MORE, self.AlwaysLoadMore:GetChecked())
  Auctionator.Config.Set(Auctionator.Config.Options.SHOPPING_COMPUTE_LIST_TOTAL, self.ComputeListTotal:GetChecked())
end
