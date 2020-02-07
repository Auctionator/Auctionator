local function InitializeCreateDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList] = {
    text = "Enter the name of the new shopping list:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
    OnAccept = function(self)
      Auctionator.ShoppingLists.Create(self.editBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
      Auctionator.ShoppingLists.Create(self:GetParent().editBox:GetText())
      self:GetParent():Hide();
    end,
    OnShow = function(self)
      self.editBox:SetText("");
      self.editBox:SetFocus();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

local function InitializeDeleteDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.DeleteShoppingList] = {
    text = "",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function(self)
      Auctionator.ShoppingLists.Delete()
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

local function InitializeAddItemDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.AddItemToShoppingList] = {
    text = "Enter the search term to add:",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
    OnAccept = function(self)
      Auctionator.ShoppingLists.AddItem(self.editBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
      Auctionator.ShoppingLists.AddItem(self:GetParent().editBox:GetText())
      self:GetParent():Hide();
    end,
    OnShow = function(self)
      self.editBox:SetText("");
      self.editBox:SetFocus();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

function Auctionator.ShoppingLists.InitializeDialogs()
  InitializeCreateDialog()
  InitializeDeleteDialog()
  InitializeAddItemDialog()
end