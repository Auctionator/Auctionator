AuctionatorShoppingListFrameMixin = {}

function AuctionatorShoppingListFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorShoppingListFrameMixin:OnLoad()")
end

function AuctionatorShoppingListFrameMixin:OnShow()
  Auctionator.Debug.Message("AuctionatorShoppingListFrameMixin:OnShow()")
  self.ScrollList:RegisterProviderEvents()
end

function AuctionatorShoppingListFrameMixin:OnHide()
  Auctionator.Debug.Message("AuctionatorShoppingListFrameMixin:OnHide()")
  self.ScrollList:UnregisterProviderEvents()
end

function AuctionatorShoppingListFrameMixin:CloseClicked()
  self:Hide()
  Auctionator.Config.Set(Auctionator.Config.Option.SHOW_LISTS, false);
end
