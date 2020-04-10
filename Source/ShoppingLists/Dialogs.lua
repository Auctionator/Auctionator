local function InitializeCreateDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.CreateShoppingList] = {
    text = AUCTIONATOR_L_CREATE_LIST_DIALOG,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
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
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

local function InitializeAddItemDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.AddItemToShoppingList] = {
    text = AUCTIONATOR_L_ADD_TERM_TO_LIST_DIALOG,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
    OnShow = function(self)
      self.editBox:SetText("");
      self.editBox:SetFocus();
    end,
    OnCancel = function()
      -- Should probably set this programatically, but :shrug:
      AuctionatorShoppingLists_AddItem:Enable()
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1
  };
end

local function InitializeRenameDialog()
  StaticPopupDialogs[Auctionator.Constants.DialogNames.RenameShoppingList] = {
    text = AUCTIONATOR_L_RENAME_LIST_DIALOG,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 32,
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
  InitializeRenameDialog()
end
