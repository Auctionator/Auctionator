StaticPopupDialogs[Auctionator.Constants.DialogNames.SellingConfirmPost] = {
  text = "",
  button1 = ACCEPT,
  button2 = CANCEL,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Selling Confirm Post Low Price Dialog")
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ConfirmPost)
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}

StaticPopupDialogs[Auctionator.Constants.DialogNames.SellingConfirmUnhideAll] = {
  text = AUCTIONATOR_L_CONFIRM_UNHIDE_ALL,
  button1 = ACCEPT,
  button2 = CANCEL,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Selling Confirm Unhide All Dialog")
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnAccept = function(self)
    Auctionator.Config.Set(Auctionator.Config.Options.SELLING_IGNORED_KEYS, {})
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.BagRefresh)
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
