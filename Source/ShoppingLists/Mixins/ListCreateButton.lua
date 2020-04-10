AuctionatorListCreateButtonMixin = {}

function AuctionatorListCreateButtonMixin:OnLoad()
  DynamicResizeButton_Resize(self)

  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList].OnAccept = function(dialog)
    self:CreateList(dialog.editBox:GetText())
  end

  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList].EditBoxOnEnterPressed = function(dialog)
    self:CreateList(dialog:GetParent().editBox:GetText())
    dialog:GetParent():Hide()
  end
end

function AuctionatorListCreateButtonMixin:OnClick()
  StaticPopup_Show(Auctionator.Constants.DialogNames.CreateShoppingList)
end

function AuctionatorListCreateButtonMixin:CreateList(listName)
  Auctionator.ShoppingLists.Create(listName)

  self:GetParent():Fire(Auctionator.ShoppingLists.Events.ListCreated, Auctionator.ShoppingLists.Lists[#Auctionator.ShoppingLists.Lists])
end