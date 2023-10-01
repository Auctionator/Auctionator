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

StaticPopupDialogs[Auctionator.Constants.DialogNames.SellingConfirmPostSkip] = {
  text = "",
  button1 = ACCEPT,
  button2 = AUCTIONATOR_L_SKIP,
  button3 = CANCEL,
  selectCallbackByIndex = true,
  OnShow = function(self)
    Auctionator.EventBus:RegisterSource(self, "Selling Confirm Post Low Price Dialog")
  end,
  OnHide = function(self)
    Auctionator.EventBus:UnregisterSource(self)
  end,
  OnButton1 = function(self)
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.ConfirmPost)
  end,
  OnButton2 = function(self)
    Auctionator.EventBus:Fire(self, Auctionator.Selling.Events.SkipItem)
  end,
  OnButton3 = function(self) end,
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
    Auctionator.Groups.UnhideAll()
    Auctionator.Groups.CallbackRegistry:TriggerEvent("Customise.EditMade")
  end,
  timeout = 0,
  exclusive = 1,
  whileDead = 1,
  hideOnEscape = 1
}
